page 50104 WebOrder
{
    Caption = 'Order';
    PageType = Document;
    SourceTable = "Order Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(order_id; Rec.order_id)
                {
                    ApplicationArea = All;
                }
                field("store id"; Rec."store id")
                {
                    ApplicationArea = All;
                }
                field("Increment id"; Rec."Increment id")
                {
                    ApplicationArea = All;
                }
                field(created_at; Rec.created_at)
                {
                    ApplicationArea = All;
                }
                field(customer_id; Rec.customer_id)
                {
                    ApplicationArea = All;
                }
                field(firstname; Rec.firstname)
                {
                    ApplicationArea = All;
                    Caption = 'First Name';
                }
                field(global_currency_code; Rec.global_currency_code)
                {
                    ApplicationArea = All;
                }
                field(lastname; Rec.lastname)
                {
                    ApplicationArea = All;
                    Caption = 'Last Name';
                }

                field(state; Rec.state)
                {
                    ApplicationArea = All;
                }
                field(status; Rec.status)
                {
                    ApplicationArea = All;
                }
                field(store_name; Rec.store_name)
                {
                    ApplicationArea = All;
                }


            }


            part(Liene; Line)
            {
                ApplicationArea = Basic, Suite;
                UpdatePropagation = Both;
                SubPageLink = order_id = field(order_id);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Update Order Line")
            {
                ApplicationArea = All;
                Promoted = true;
                trigger OnAction()
                var
                    MagentoAPI: Codeunit MagentoAPI;
                begin
                    MagentoAPI.GetOrderDetails(Rec."Increment id");

                end;
            }
        }
    }

}
