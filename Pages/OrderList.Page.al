page 50102 "Order List"
{

    ApplicationArea = All;
    Caption = 'Order List';
    PageType = List;
    SourceTable = "Order Header";
    UsageCategory = Lists;
    CardPageId = WebOrder;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(order_id; Rec.order_id)
                {
                    ApplicationArea = All;
                }
                field("Increment id"; Rec."Increment id")
                {
                    ApplicationArea = All;
                }

                field("store id"; Rec."store id")
                {
                    ApplicationArea = All;
                }
                field(firstname; Rec.firstname)
                {
                    ApplicationArea = All;
                }
                field(lastname; Rec.lastname)
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
                    Visible = false;
                }
                field(state; Rec.state)
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
                field(global_currency_code; Rec.global_currency_code)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Get New Order")
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    Magento: Codeunit MagentoAPI;
                begin
                    Magento.GerOrderList('10'); // Save Last Updated Order In Setup Page
                end;
            }

        }
    }
}
