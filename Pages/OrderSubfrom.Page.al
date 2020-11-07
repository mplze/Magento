page 50103 Line
{
    
    Caption = 'Line';
    PageType = ListPart;
    SourceTable = "Order Line";
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(item_id; Rec.item_id)
                {
                    ApplicationArea = All;
                }
                field(product_id; Rec.product_id)
                {
                    ApplicationArea = All;
                }
                field(name; Rec.name)
                {
                    ApplicationArea = All;
                }
                field(price; Rec.price)
                {
                    ApplicationArea = All;
                }
                field(qty_ordered; Rec.qty_ordered)
                {
                    ApplicationArea = All;
                }
                field(sku; Rec.sku)
                {
                    ApplicationArea = All;
                }
                field(tax_amount; Rec.tax_amount)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    
}
