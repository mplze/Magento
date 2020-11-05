table 50100 "Magento Setup"
{
    Caption = 'Magento Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = ToBeClassified;
        }
        field(2; "API User Name"; Text[50])
        {
            Caption = 'API User Name';
            DataClassification = ToBeClassified;
        }
        field(3; "API key"; Text[50])
        {
            Caption = 'API key';
            DataClassification = ToBeClassified;
        }
        field(4; "API URL"; Text[100])
        {
            Caption = 'API URL';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

}
