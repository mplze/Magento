report 50100 "Magento Item List"
{

    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Magento Item List';
    RDLCLayout = './ReportLayout/MagentoItemList.rdl';


    dataset
    {
        dataitem("Magento Item"; "Magento Item")
        {

            column(ProductID; "Product ID")
            {
            }
            column(Name; Name)
            {
            }
            column(SKU; SKU)
            {
            }
            column(Inventory; Inventory)
            {
            }
        }
    }


}