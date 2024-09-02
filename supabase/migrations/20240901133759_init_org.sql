-- Create a table for organizations

CREATE TABLE organizations(
    id serial PRIMARY KEY,
    name text NOT NULL,
    slug text UNIQUE NOT NULL,
    bio text,
    website text,
    created_at timestamp with time zone DEFAULT now()
);

CREATE TYPE organisation_roles AS enum(
    'Admin',
    'Staff'
);

CREATE TABLE organization_members(
    id serial PRIMARY KEY,
    organization_id int NOT NULL REFERENCES public.organizations ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES public.profiles ON DELETE CASCADE,
    ROLE organisation_roles NOT NULL DEFAULT 'Staff'
);

CREATE TABLE organization_invitations(
    id serial PRIMARY KEY,
    organization_id int NOT NULL REFERENCES public.organizations ON DELETE CASCADE,
    email text NOT NULL,
    ROLE organisation_roles NOT NULL DEFAULT 'Staff',
    created_at timestamp with time zone DEFAULT now()
);

CREATE VIEW user_organizations AS
SELECT
    organization_id,
    ROLE
FROM
    organization_members
WHERE
    user_id = auth.uid();

ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Organization profiles are viewable by everyone." ON organizations
    FOR SELECT TO anon, authenticated
        USING (TRUE);

CREATE POLICY "Users can create organization profiles." ON organizations
    FOR INSERT TO authenticated
        WITH CHECK (TRUE);

CREATE POLICY "Admins can update their organization profiles." ON organizations
    FOR UPDATE TO authenticated
        USING (id IN (
            SELECT
                organization_id
            FROM
                user_organizations
            WHERE
                ROLE = 'Admin'));

ALTER TABLE organization_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users can view their organization membership" ON organization_members
    FOR SELECT TO authenticated
        USING ((
            SELECT
                auth.uid()) = user_id);

CREATE POLICY "Users can view their organization members" ON organization_members
    FOR SELECT TO authenticated
        USING (organization_id IN (
            SELECT
                organization_id
            FROM
                user_organizations));

CREATE POLICY "Invited users can join the organization" ON organization_members
    FOR INSERT TO authenticated
        WITH CHECK (organization_id IN (
            SELECT
                organization_id
            FROM
                organization_invitations
            WHERE
                email =(
                    SELECT
                        auth.jwt() ->> 'email')));

CREATE POLICY "Admins can update their organization members role" ON organization_members
    FOR UPDATE TO authenticated
        USING (organization_id IN (
            SELECT
                organization_id
            FROM
                user_organizations
            WHERE
                ROLE = 'Admin'));

CREATE POLICY "Admins can remove their organization members and members can leave" ON organization_members
    FOR DELETE TO authenticated
        USING (((
            SELECT
                auth.uid()) = user_id)
                OR (organization_id IN (
                    SELECT
                        organization_id
                    FROM
                        user_organizations
                    WHERE
                        ROLE = 'Admin')));

ALTER TABLE organization_invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins and invited user can view the organization invitations" ON organization_invitations
    FOR SELECT TO authenticated
        USING ((organization_id IN (
            SELECT
                organization_id
            FROM
                user_organizations
            WHERE
                ROLE = 'Admin'))
                OR (email =(
                    SELECT
                        auth.jwt() ->> 'email')));

CREATE POLICY "Organization Admins can invite users" ON organization_invitations
    FOR INSERT TO authenticated
        WITH CHECK (organization_id IN (
            SELECT
                organization_id
            FROM
                user_organizations
            WHERE
                ROLE = 'Admin'));

CREATE POLICY "Organization Admins can cancel invites or invited user can reject" ON organization_invitations
    FOR DELETE TO authenticated
        USING ((email =(
            SELECT
                auth.jwt() ->> 'email'))
                OR (organization_id IN (
                    SELECT
                        organization_id
                    FROM
                        user_organizations
                    WHERE
                        ROLE = 'Admin')));

CREATE OR REPLACE FUNCTION add_organization_owner()
    RETURNS TRIGGER
    AS $$
BEGIN
    INSERT INTO organization_members(organization_id, user_id, ROLE)
        VALUES(NEW.id,(
                SELECT
                    auth.uid()),
                'Admin');
    RETURN new;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER;

CREATE TRIGGER add_organization_owner_on_creation
    AFTER INSERT ON public.organizations
    FOR EACH ROW
    EXECUTE PROCEDURE public.add_organization_owner();

CREATE OR REPLACE FUNCTION safe_leave_organization()
    RETURNS TRIGGER
    AS $$
BEGIN
    -- prevent org member deletion if there is only one admin left and that is being deleted
    IF(OLD.role = 'Admin') THEN
        IF(
            SELECT
                count(*) = 0
            FROM
                organization_members
            WHERE
                organization_id = OLD.organization_id AND ROLE = 'Admin' AND user_id != OLD.user_id) THEN
            RAISE EXCEPTION 'An organization requires atlest 1 admin.';
        END IF;
    END IF;
    RETURN old;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER;

CREATE TRIGGER safe_leave_organization
    BEFORE DELETE ON public.organization_members
    FOR EACH ROW
    EXECUTE PROCEDURE public.safe_leave_organization();

CREATE OR REPLACE FUNCTION invite_only_new_user_to_organization()
    RETURNS TRIGGER
    AS $$
BEGIN
    -- prevent sending invites to user already invited or existing member of organization
    IF EXISTS(
        SELECT
            *
        FROM
            organization_invitations
        WHERE
            email = NEW.email
            AND organization_id = NEW.organization_id) THEN
    RAISE EXCEPTION 'User has already been invited.';
    ELSEIF EXISTS(
        SELECT
            id
        FROM
            profiles
        WHERE
            email = NEW.email) THEN
    IF EXISTS(
        SELECT
            id
        FROM
            organization_members
        WHERE
            user_id =(
                SELECT
                    id
                FROM
                    profiles
                WHERE
                    email = NEW.email)
                AND organization_id = NEW.organization_id) THEN
        RAISE EXCEPTION 'User is already a member of the organization.';
END IF;
END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER;

CREATE TRIGGER invite_only_new_user_to_organization
    BEFORE INSERT ON organization_invitations
    FOR EACH ROW
    EXECUTE PROCEDURE invite_only_new_user_to_organization();


-- delete invitation when user joins the organization
CREATE OR REPLACE FUNCTION delete_invitation_on_join()
    RETURNS TRIGGER
    AS $$
BEGIN
    DELETE FROM organization_invitations
    WHERE
        email =(SELECT auth.jwt() ->> 'email')
            AND organization_id = NEW.organization_id;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER;

CREATE TRIGGER delete_invitation_on_join
    AFTER INSERT ON organization_members
    FOR EACH ROW
    EXECUTE PROCEDURE delete_invitation_on_join();