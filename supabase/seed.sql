INSERT INTO invoice_templates (name, description, header, sections, footer, invoice_number_prefix)
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
    ]', 'Thank you for your purchase!', 'UNI'),
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
    ]', 'Thank you for supporting the library!', 'LIB'),
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
    ]', 'Thank you for your prompt payment!', 'HOSP'),
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
    ]', 'Thank you for maintaining our city!', 'DEPT');