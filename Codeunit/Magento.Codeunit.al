codeunit 50100 MagentoAPI
{
    trigger OnRun()
    begin

    end;

    procedure Login(): Boolean
    var
        HttpHeader: HttpHeaders;
        HttpContent: HttpContent;
        Payload: Text;
        TextResponse: Text;
        ResponseErr: Label 'Response Error %1', Comment = '%1 Response error ';
        ResponseReadErr: Label 'Response Cannot Read error';
        LoginResponseXML: XmlDocument;
        SessionIdNode: XmlNode;
    begin
        GetSetup();

        Payload := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">' +
                    '<soapenv:Header/>' +
                        '<soapenv:Body>' +
                            '<urn:login soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
                            '<username xsi:type="xsd:string">' + MagentoSetup."API User Name" + '</username>' +
                            '<apiKey xsi:type="xsd:string">' + MagentoSetup."API key" + '</apiKey>' +
                            '</urn:login>' +
                        '</soapenv:Body>' +
                    '</soapenv:Envelope>';

        HttpContent.Clear();
        HttpContent.WriteFrom(Payload);
        HttpContent.GetHeaders(HttpHeader);
        HttpHeader.Clear();
        HttpHeader.Add('Content-Type', 'text/xml;charset=UTF-8');
        HttpHeader.Add('Action', 'urn:Action');

        TextResponse := POST(Payload, HttpContent);

        XmlDocument.ReadFrom(TextResponse, LoginResponseXML);

        if LoginResponseXML.SelectSingleNode('//loginReturn', SessionIdNode) then begin
            SessionId := SessionIdNode.AsXmlElement().InnerText();
            exit(true);
        end else
            if LoginResponseXML.SelectSingleNode('//faultstring', SessionIdNode) then
                Error(SessionIdNode.AsXmlElement().InnerText);

    end;




    local procedure POST(Payload: Text; var HttpContent: HttpContent): Text
    var
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        TextResponse: Text;
        ResponseErr: Label 'Response Error %1', Comment = '%1 Response error ';
        ResponseReadErr: Label 'Response Cannot Read error';
    begin
        GetSetup();

        HttpClient.Post(MagentoSetup."API URL", HttpContent, HttpResponse);

        if not HttpResponse.IsSuccessStatusCode then
            Error(ResponseErr, HttpResponse.HttpStatusCode);

        if HttpResponse.Content.ReadAs(TextResponse) then
            exit(TextResponse)
        else
            Error(ResponseReadErr);
    end;

    local procedure GetSetup()
    begin
        MagentoSetup.Get();
        MagentoSetup.TestField("API User Name");
        MagentoSetup.TestField("API key");
        MagentoSetup.TestField("API URL");
    end;


    var
        SessionId: Text;
        MagentoSetup: Record "Magento Setup";

}