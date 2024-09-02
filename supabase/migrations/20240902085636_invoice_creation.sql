-- trigger to generate invoice number for new invoices
CREATE SEQUENCE invoice_seq;

CREATE FUNCTION public.generate_invoice_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.invoice_number = NEW.invoice_number || '-' || lpad(nextval('invoice_seq')::text, 4, '0');
    RETURN NEW;
END;
$$
LANGUAGE plpgsql
SECURITY DEFINER;


CREATE TRIGGER generate_invoice_number_trigger
    BEFORE INSERT ON public.invoices
    FOR EACH ROW
    EXECUTE PROCEDURE public.generate_invoice_number();