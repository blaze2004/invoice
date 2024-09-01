INSERT INTO invoice_templates (name, description, header, sections, footer)
VALUES
('University Purchase Invoice', 'Template for university purchases like books and computers', '{
        "title": "University Purchase Invoice",
        "details": [
            {
                "label": "University Name",
                "value": "University of Example"
            },
            {
                "label": "Address",
                "value": "123 University Ave, City, Country"
            }
        ]
    }', '[
        {
            "title": "Invoice Details",
            "fields": [
                {
                    "label": "Invoice Number",
                    "value": "PUR-001",
                    "editable": false,
                    "type": "text"
                },
                {
                    "label": "Date",
                    "value": "2024-08-01",
                    "editable": true,
                    "type": "date"
                },
                {
                    "label": "Due Date",
                    "value": "2024-08-31",
                    "editable": true,
                    "type": "date"
                }
            ]
        },
        {
            "title": "Books",
            "showQuantity": true,
            "currency": "USD",
            "items": [
                {
                    "description": "Introduction to Algorithms",
                    "amount": 80,
                    "quantity": 20
                },
                {
                    "description": "Advanced Mathematics",
                    "amount": 50,
                    "quantity": 15
                }
            ]
        },
        {
            "title": "Computers",
            "showQuantity": true,
            "currency": "USD",
            "items": [
                {
                    "description": "Dell Laptops",
                    "amount": 700,
                    "quantity": 10
                },
                {
                    "description": "HP Desktops",
                    "amount": 1000,
                    "quantity": 5
                }
            ]
        }
    ]', 'Thank you for your purchase!'),
('Public Library Acquisition Invoice', 'Template for public library acquisitions and maintenance', '{
        "title": "Public Library Acquisition Invoice",
        "details": [
            {
                "label": "Library Name",
                "value": "City Public Library"
            },
            {
                "label": "Address",
                "value": "456 Library St, City, Country"
            }
        ]
    }', '[
        {
            "title": "Invoice Details",
            "fields": [
                {
                    "label": "Invoice Number",
                    "value": "LIB-001",
                    "editable": false,
                    "type": "text"
                },
                {
                    "label": "Date",
                    "value": "2024-07-20",
                    "editable": true,
                    "type": "date"
                },
                {
                    "label": "Due Date",
                    "value": "2024-08-20",
                    "editable": true,
                    "type": "date"
                }
            ]
        },
        {
            "title": "New Books Collection",
            "showQuantity": true,
            "currency": "USD",
            "items": [
                {
                    "description": "Fiction Novels",
                    "amount": 15,
                    "quantity": 50
                },
                {
                    "description": "Science Journals",
                    "amount": 30,
                    "quantity": 20
                }
            ]
        },
        {
            "title": "Library Maintenance",
            "showQuantity": false,
            "currency": "USD",
            "items": [
                {
                    "description": "Monthly Cleaning Services",
                    "amount": 300
                }
            ]
        }
    ]', 'Thank you for supporting the library!'),
('Hospital Medical Supplies Invoice', 'Template for hospital medical supplies and equipment', '{
        "title": "Hospital Medical Supplies Invoice",
        "details": [
            {
                "label": "Hospital Name",
                "value": "City General Hospital"
            },
            {
                "label": "Address",
                "value": "789 Hospital Rd, City, Country"
            }
        ]
    }', '[
        {
            "title": "Invoice Details",
            "fields": [
                {
                    "label": "Invoice Number",
                    "value": "MED-001",
                    "editable": false,
                    "type": "text"
                },
                {
                    "label": "Date",
                    "value": "2024-09-01",
                    "editable": true,
                    "type": "date"
                },
                {
                    "label": "Due Date",
                    "value": "2024-09-30",
                    "editable": true,
                    "type": "date"
                }
            ]
        },
        {
            "title": "Medical Equipment",
            "showQuantity": true,
            "currency": "USD",
            "items": [
                {
                    "description": "X-ray Machines",
                    "amount": 15000,
                    "quantity": 2
                },
                {
                    "description": "Ultrasound Scanners",
                    "amount": 10000,
                    "quantity": 3
                }
            ]
        },
        {
            "title": "Pharmaceuticals",
            "showQuantity": true,
            "currency": "USD",
            "items": [
                {
                    "description": "Pain Relievers",
                    "amount": 5,
                    "quantity": 1000
                },
                {
                    "description": "Antibiotics",
                    "amount": 10,
                    "quantity": 500
                }
            ]
        }
    ]', 'Thank you for your prompt payment!'),
('City Department Maintenance Invoice', 'Template for city department maintenance services', '{
        "title": "City Department Maintenance Invoice",
        "details": [
            {
                "label": "Department Name",
                "value": "City Public Works"
            },
            {
                "label": "Address",
                "value": "101 City Hall, City, Country"
            }
        ]
    }', '[
        {
            "title": "Invoice Details",
            "fields": [
                {
                    "label": "Invoice Number",
                    "value": "MAINT-001",
                    "editable": false,
                    "type": "text"
                },
                {
                    "label": "Date",
                    "value": "2024-07-15",
                    "editable": true,
                    "type": "date"
                },
                {
                    "label": "Due Date",
                    "value": "2024-08-14",
                    "editable": true,
                    "type": "date"
                }
            ]
        },
        {
            "title": "Road Repairs",
            "showQuantity": false,
            "currency": "USD",
            "items": [
                {
                    "description": "Pothole Filling",
                    "amount": 5000
                }
            ]
        },
        {
            "title": "Park Maintenance",
            "showQuantity": false,
            "currency": "USD",
            "items": [
                {
                    "description": "Monthly Lawn Care",
                    "amount": 2000
                },
                {
                    "description": "Tree Pruning",
                    "amount": 1500
                }
            ]
        }
    ]', 'Thank you for maintaining our city!');