-- Invoice Templates Table
CREATE TABLE invoice_templates (
    id serial PRIMARY KEY,
    organization_id int REFERENCES public.organizations ON DELETE Set NULL,
    name TEXT NOT NULL,
    description TEXT,
    header JSON NOT NULL,
    sections JSON NOT NULL,
    footer Text,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    created_by uuid REFERENCES public.profiles ON DELETE Set NULL DEFAULT (auth.uid())
);

CREATE TYPE invoice_status AS ENUM (
    'Draft',
    'In Review',
    'Sent',
    'Paid',
    'Overdue'
);

-- Invoices Table
CREATE TABLE invoices (
    id serial PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    invoice_number TEXT NOT NULL,
    client Json NOT NULL,
    issue_date DATE,
    due_date DATE,
    total_amount NUMERIC(10,2) NOT NULL,
    template_id int NOT NULL REFERENCES invoice_templates,
    template_fields JSON NOT NULL,
    status invoice_status NOT NULL DEFAULT 'Draft',
    created_by uuid REFERENCES profiles ON DELETE CASCADE DEFAULT (auth.uid()),
    organization_id int NOT NULL REFERENCES organizations ON DELETE CASCADE
);

-- rls 

ALTER TABLE invoice_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public Invoice Templates are viewable by everyone and Org members can view org invoice templates." ON invoice_templates
    FOR SELECT TO authenticated
        USING (
            organization_id IN (
            SELECT
                organization_id
            FROM
                user_organizations)
                or 
                (organization_id is NULL)
        );

CREATE POLICY "Users can create invoice templates." ON invoice_templates
    FOR INSERT TO authenticated
        WITH CHECK (TRUE);

CREATE POLICY "Users can update their invoice templates." ON invoice_templates
    FOR UPDATE TO authenticated
        USING (
            organization_id IN (
            SELECT
                organization_id
            FROM
                user_organizations
            WHERE
                ROLE = 'Admin')
                or 
            (created_by = auth.uid())
        );


ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Org members can view org invoices." ON invoices
    FOR SELECT TO authenticated
        USING (
            organization_id IN (
            SELECT
                organization_id
            FROM
                user_organizations)
        );

CREATE POLICY "Org members can create invoices." ON invoices
    FOR INSERT TO authenticated
        WITH CHECK (
            organization_id IN (
            SELECT
                organization_id
            FROM
                user_organizations)
);

CREATE POLICY "Users can update their invoices." ON invoices
    FOR UPDATE TO authenticated
        USING (
            organization_id IN (
            SELECT
                organization_id
            FROM
                user_organizations
                WHERE
                ROLE = 'Admin')
                or 
            (created_by = auth.uid())
        );

CREATE POLICY "Users can delete their invoices." ON invoices
    FOR DELETE TO authenticated
        USING (
            organization_id IN (
            SELECT
                organization_id
            FROM
                user_organizations
                WHERE
                ROLE = 'Admin')
                or 
            (created_by = auth.uid())
        );