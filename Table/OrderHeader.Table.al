table 50102 "Order Header"
{
    Caption = 'Order Header';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; order_id; code[50])
        {
            Caption = 'order_id';
            DataClassification = ToBeClassified;
        }
        field(2; "Increment id"; Code[50])
        {
            Caption = 'Increment id';
            DataClassification = ToBeClassified;
        }
        field(3; "store id"; Code[10])
        {
            Caption = 'store id';
            DataClassification = ToBeClassified;
        }
        field(4; created_at; Text[100])
        {
            Caption = 'created_at';
            DataClassification = ToBeClassified;
        }
        field(5; store_name; Text[100])
        {
            Caption = 'store_name';
            DataClassification = ToBeClassified;
        }
        field(6; status; Text[100])
        {
            Caption = 'status';
            DataClassification = ToBeClassified;
        }
        field(7; state; Text[100])
        {
            Caption = 'state';
            DataClassification = ToBeClassified;
        }
        field(8; global_currency_code; Text[100])
        {
            Caption = 'global_currency_code';
            DataClassification = ToBeClassified;
        }
        field(9; firstname; Text[100])
        {
            Caption = 'firstname';
            DataClassification = ToBeClassified;
        }
        field(10; lastname; Text[100])
        {
            Caption = 'lastname';
            DataClassification = ToBeClassified;
        }
        field(11; customer_id; Text[100])
        {
            Caption = 'customer_id';
            DataClassification = ToBeClassified;
        }

    }
    keys
    {
        key(PK; order_id)
        {
            Clustered = true;
        }
    }

}
