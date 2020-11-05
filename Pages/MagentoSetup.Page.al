page 50100 "Magento Setup"
{

    Caption = 'Magento Setup';
    PageType = Card;
    SourceTable = "Magento Setup";
    ApplicationArea = all;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("API URL"; Rec."API URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter API URL';
                }
                field("API User Name"; Rec."API User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter API User Name';
                }
                field("API key"; Rec."API key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter API Key';
                }

            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(Login)
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    magentoAPI: Codeunit MagentoAPI;
                begin
                    magentoAPI.Login();

                end;
            }
        }
    }





    trigger OnOpenPage()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}
