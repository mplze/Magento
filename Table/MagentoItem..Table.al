table 50101 "Magento Item"
{
    Caption = 'Magento Item List';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Product ID"; Code[20])
        {
            Caption = 'Product ID';
            DataClassification = ToBeClassified;
        }
        field(2; SKU; Text[20])
        {
            Caption = 'SKU';
            DataClassification = ToBeClassified;
        }
        field(3; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(4; Set; Text[20])
        {
            Caption = 'Set';
            DataClassification = ToBeClassified;
        }
        field(6; Type; Text[20])
        {
            Caption = 'Set';
            DataClassification = ToBeClassified;
        }
        field(7; Inventory; Decimal)
        {
            Caption = 'Inventory';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Product ID")
        {
            Clustered = true;
        }
    }

}
