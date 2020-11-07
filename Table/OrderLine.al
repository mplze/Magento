table 50103 "Order Line"
{
    Caption = 'Order Line';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; order_id; Code[50])
        {
            Caption = 'order_id';
            DataClassification = ToBeClassified;
        }
        field(2; "Line No"; Integer)
        {
            Caption = 'Line No';
            DataClassification = ToBeClassified;
        }
        field(3; item_id; Text[20])
        {
            Caption = 'item_id';
            DataClassification = ToBeClassified;
        }
        field(4; product_id; Code[20])
        {
            Caption = 'product_id';
            DataClassification = ToBeClassified;
        }
        field(5; sku; Text[20])
        {
            Caption = 'sku';
            DataClassification = ToBeClassified;
        }
        field(6; name; Text[100])
        {
            Caption = 'name';
            DataClassification = ToBeClassified;
        }
        field(7; qty_ordered; Decimal)
        {
            Caption = 'qty_ordered';
            DataClassification = ToBeClassified;
        }
        field(8; price; Decimal)
        {
            Caption = 'price';
            DataClassification = ToBeClassified;
        }
        field(9; tax_amount; Decimal)
        {
            Caption = 'tax_amount';
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

    procedure GetNextLineNo(OrderID: Code[50]): Integer
    var
        orderLine: Record "Order Line";
    begin
        orderLine.Reset();
        orderLine.SetRange(order_id, OrderID);
        if orderLine.FindLast() then
            exit(orderLine."Line No" + 1000)
        else
            exit(1000);

    end;

}
