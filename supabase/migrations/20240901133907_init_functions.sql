-- Function to generate unique slug for a given string
CREATE FUNCTION public.generate_unique_slug(base_string text, schema_name text, table_name text, column_name text DEFAULT 'slug')
RETURNS text
SET search_path = ''
AS $$
DECLARE
    base_slug text := lower(regexp_replace(base_string, '[^a-zA-Z0-9]+', '-', 'g'));
    unique_slug text := base_slug;
    slug_exists boolean;
    counter int := 0;
    query text;
BEGIN
    -- Ensure the base slug has at least 6 characters
    IF length(base_slug) < 6 THEN
        base_slug := base_slug || repeat('-', 6 - length(base_slug));
    END IF;

    -- Build dynamic query to check if the slug exists, using schema and table name separately
    query := format('SELECT EXISTS(SELECT 1 FROM %I.%I WHERE %I = %L)', schema_name, table_name, column_name, unique_slug);
    
    -- Check if the base slug exists
    EXECUTE query INTO slug_exists;

    -- Append counter to base_slug if it exists
    WHILE slug_exists LOOP
        counter := counter + 1;
        unique_slug := base_slug || '-' || counter;
        query := format('SELECT EXISTS(SELECT 1 FROM %I.%I WHERE %I = %L)', schema_name, table_name, column_name, unique_slug);
        EXECUTE query INTO slug_exists;
    END LOOP;

    RETURN unique_slug;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER;



CREATE OR REPLACE FUNCTION generate_organization_slug_trigger()
    RETURNS TRIGGER
    AS $$
BEGIN
    -- Generate a unique slug based on the organization name if slug is empty
    IF NEW.slug IS NULL OR NEW.slug = '' THEN
        NEW.slug := public.generate_unique_slug(NEW.name, 'public', 'organizations');
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER;

CREATE TRIGGER generate_organization_slug_on_insert
    BEFORE INSERT ON organizations
    FOR EACH ROW
    EXECUTE PROCEDURE generate_organization_slug_trigger();