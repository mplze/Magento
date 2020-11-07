page 50101 "Magento Items"
{

    ApplicationArea = All;
    Caption = 'Magento Item List';
    PageType = List;
    SourceTable = "Magento Item";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Product ID"; Rec."Product ID")
                {
                    ApplicationArea = All;
                }
                field(SKU; Rec.SKU)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Set; Rec.Set)
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(Inventory; Rec.Inventory)
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
            action("Update Item List")
            {
                ApplicationArea = All;
                Caption = 'Update Items';
                ToolTip = 'Update Item master details';
                Image = Item;


                trigger OnAction()
                var
                    MagentoAPI: Codeunit MagentoAPI;
                    ActionMsg: Label 'Item Master updated';
                begin
                    MagentoAPI.GetCatalogProductList();
                    Message(ActionMsg);
                end;
            }

            action("Update Inventory")
            {
                ApplicationArea = All;
                Caption = 'Update Inventory';
                ToolTip = 'Update Inventory';
                Promoted = true;
                Image = Inventory;
                PromotedIsBig = false;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    MagentoAPI: Codeunit MagentoAPI;
                    ItemList: Record "Magento Item";
                    TxtItemList: TextBuilder;
                    ActionMsg: Label 'Inventory update Completed';
                begin
                    CurrPage.SetSelectionFilter(ItemList);

                    if ItemList.FindSet() then
                        repeat
                            MagentoAPI.GenerateItemList(TxtItemList, ItemList."Product ID");
                        until ItemList.Next() = 0;

                    MagentoAPI.GetCatalogInventoryStockItemList(TxtItemList);
                    Message(ActionMsg);
                end;
            }



        }


    }


}
