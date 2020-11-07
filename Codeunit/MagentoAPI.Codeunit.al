codeunit 50100 MagentoAPI
{
    trigger OnRun()
    begin

    end;

    local procedure GetSetup()
    begin
        MagentoSetup.Get();
        MagentoSetup.TestField("API User Name");
        MagentoSetup.TestField("API key");
        MagentoSetup.TestField("API URL");
    end;



    local procedure POST(var HttpContent_: HttpContent): Text
    var
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        TextResponse: Text;
        ResponseErr: Label 'Response Error %1', Comment = '%1 Response error ';
        ResponseReadErr: Label 'Response Cannot Read error';
        Data: Text;
    begin
        HttpClient.Clear();
        Clear(HttpResponse);
        Clear(TextResponse);

        HttpContent_.ReadAs(Data);

        if NOT HttpClient.Post(MagentoSetup."API URL", HttpContent_, HttpResponse) then
            Error('Http Client Error');

        if not HttpResponse.IsSuccessStatusCode then
            Error(ResponseErr, HttpResponse.ReasonPhrase);

        if HttpResponse.Content.ReadAs(TextResponse) then
            exit(TextResponse)
        else
            Error(ResponseReadErr);
    end;

    procedure Login(): Boolean
    var
        HttpHeader: HttpHeaders;
        HttpContent: HttpContent;
        Payload: Text;
        TextResponse: Text;
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

        TextResponse := POST(HttpContent);

        XmlDocument.ReadFrom(TextResponse, LoginResponseXML);

        if LoginResponseXML.SelectSingleNode('//loginReturn', SessionIdNode) then begin
            SessionId := SessionIdNode.AsXmlElement().InnerText();
            exit(true);
        end else
            if LoginResponseXML.SelectSingleNode('//faultstring', SessionIdNode) then
                Error(SessionIdNode.AsXmlElement().InnerText);

    end;

    local procedure EndSession()
    var
        HttpHeader: HttpHeaders;
        Httpontents: HttpContent;
        Payload: Text;
        TextResponse: Text;
    begin
        Payload :=
        '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">' +
            '< soapenv:Header/>' +
                '<soapenv:Body>' +
                    '<urn:endSession soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
                    '<sessionId xsi:type="xsd:string">' + SessionId + '</sessionId>' +
                '</urn:endSession>' +
            '</soapenv:Body>' +
        '</soapenv:Envelope>';

        Httpontents.Clear();
        Httpontents.WriteFrom(Payload);
        Httpontents.GetHeaders(HttpHeader);
        HttpHeader.Clear();
        HttpHeader.Add('Content-Type', 'text/xml;charset=UTF-8');
        HttpHeader.Add('Action', 'urn:Action');
        TextResponse := POST(Httpontents);
    end;

    procedure GetCatalogProductList()
    var
        MagentoItem: Record "Magento Item";
        HttpHeader: HttpHeaders;
        HttpContent: HttpContent;
        Payload: Text;
        TextResponse: Text;
        ProductListXMLDoc: XmlDocument;
        ItemListXMLDoc: XmlDocument;
        ItemListNode: XmlNodeList;
        ItemNode: XmlNode;
        ProductIDNode: XmlNode;
        SKUNode: XmlNode;
        NameNode: XmlNode;
        SetNode: XmlNode;
        TypeNode: XmlNode;
        TxtItemsNode: Text;
        i: Integer;

    begin
        Login();
        MagentoSetup.TestField("Store View");

        Payload := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">' +
         '<soapenv:Header/>' +
         '<soapenv:Body>' +
            '<urn:catalogProductList soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
               '<sessionId xsi:type="xsd:string">' + SessionId + '</sessionId>' +
                '<storeView xsi:type="xsd:string">' + MagentoSetup."Store View" + '</storeView>' +
            '</urn:catalogProductList>' +
         '</soapenv:Body>' +
      '</soapenv:Envelope>';

        HttpContent.Clear();
        HttpContent.WriteFrom(Payload);
        HttpContent.GetHeaders(HttpHeader);
        HttpHeader.Clear();
        HttpHeader.Add('Content-Type', 'text/xml;charset=UTF-8');
        HttpHeader.Add('Action', 'urn:Action');

        TextResponse := POST(HttpContent);


        XmlDocument.ReadFrom(TextResponse, ProductListXMLDoc);
        if ProductListXMLDoc.SelectNodes('//storeView/item', ItemListNode) then
            for i := 1 to ItemListNode.Count do begin
                ItemListNode.Get(i, ItemNode);
                TxtItemsNode := ItemNode.AsXmlElement().InnerXml();
                TxtItemsNode := StrSubstNo('%1%2%3', '<Items>', TxtItemsNode, '</Items>');

                XmlDocument.ReadFrom(TxtItemsNode, ItemListXMLDoc);
                ItemListXMLDoc.SelectSingleNode('//product_id', ProductIDNode);
                ItemListXMLDoc.SelectSingleNode('//sku', SKUNode);
                ItemListXMLDoc.SelectSingleNode('//name', NameNode);
                ItemListXMLDoc.SelectSingleNode('//set', SetNode);
                ItemListXMLDoc.SelectSingleNode('//type', TypeNode);

                if MagentoItem.Get(ProductIDNode.AsXmlElement().InnerText()) then begin
                    MagentoItem.SKU := SKUNode.AsXmlElement().InnerText();
                    MagentoItem.Name := NameNode.AsXmlElement().InnerText();
                    MagentoItem.Set := SetNode.AsXmlElement().InnerText();
                    MagentoItem.Type := TypeNode.AsXmlElement().InnerText();

                    MagentoItem.Modify();
                end else begin
                    MagentoItem.Init();
                    MagentoItem."Product ID" := ProductIDNode.AsXmlElement().InnerText();
                    MagentoItem.SKU := SKUNode.AsXmlElement().InnerText();
                    MagentoItem.Name := NameNode.AsXmlElement().InnerText();
                    MagentoItem.Set := SetNode.AsXmlElement().InnerText();
                    MagentoItem.Type := TypeNode.AsXmlElement().InnerText();
                    MagentoItem.Insert();
                end;
            end;
    end;



    procedure GenerateItemList(var ItemList: TextBuilder; ItemNo: code[20])
    begin
        ItemList.Append('<item xsi:type="xsd:string">' + ItemNo + '</item>')
    end;


    procedure GetCatalogInventoryStockItemList(var ItemList: TextBuilder)
    var
        MagentoItemList: Record "Magento Item";
        HttpHeader: HttpHeaders;
        HttpContent: HttpContent;
        Payload: Text;
        TextResponse: Text;
        ItemTags: Text;
        ProductListXMLDoc: XmlDocument;
        ItemListXMLDoc: XmlDocument;
        ItemListNode: XmlNodeList;
        ItemNode: XmlNode;
        ProductIDNode: XmlNode;
        QtyNode: XmlNode;
        TxtItemsNode: Text;
        i: Integer;

    begin
        Login();
        ItemTags := ItemList.ToText();
        Payload :=
        '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">' +
            '<soapenv:Header/>' +
                '<soapenv:Body>' +
                    '<urn:catalogInventoryStockItemList soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
                    '<sessionId xsi:type="xsd:string">' + SessionId + '</sessionId>' +
                    '<products SOAP-ENC:arrayType="xsd:string[1]" xsi:type="ns1:ArrayOfString">' + ItemTags + '</products>' +
                '</urn:catalogInventoryStockItemList>' +
                '</soapenv:Body>' +
            '</soapenv:Envelope>';

        HttpContent.Clear();
        HttpContent.WriteFrom(Payload);
        HttpContent.GetHeaders(HttpHeader);
        HttpHeader.Clear();
        HttpHeader.Add('Content-Type', 'text/xml;charset=UTF-8');
        HttpHeader.Add('Action', 'urn:Action');

        TextResponse := POST(HttpContent);

        XmlDocument.ReadFrom(TextResponse, ProductListXMLDoc);
        if ProductListXMLDoc.SelectNodes('//result/item', ItemListNode) then
            for i := 1 to ItemListNode.Count do begin
                ItemListNode.Get(i, ItemNode);
                TxtItemsNode := ItemNode.AsXmlElement().InnerXml();
                TxtItemsNode := StrSubstNo('%1%2%3', '<Items>', TxtItemsNode, '</Items>');

                XmlDocument.ReadFrom(TxtItemsNode, ItemListXMLDoc);
                ItemListXMLDoc.SelectSingleNode('//product_id', ProductIDNode);
                ItemListXMLDoc.SelectSingleNode('//qty', QtyNode);

                if MagentoItemList.Get(ProductIDNode.AsXmlElement().InnerText()) then begin
                    Evaluate(MagentoItemList.Inventory, QtyNode.AsXmlElement().InnerText());
                    MagentoItemList.Modify();
                end;
            end;
    end;


    procedure GerOrderList(LastOrderID: Text)
    var
        OrderHdr: Record "Order Header";
        HttpHeader: HttpHeaders;
        HttpContent: HttpContent;
        Payload: Text;
        TextResponse: Text;
        TxtOrderNode: Text;
        order_id: Code[10];

        OrderListXMLDoc: XmlDocument;
        OrderXMLDoc: XmlDocument;
        OrderListNode: XmlNodeList;
        OrderNode: XmlNode;
        LineNode: XmlNode;
        i: Integer;
    begin
        Login();

        Payload :=
            '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">' +
                '<soapenv:Header/>' +
                '<soapenv:Body>' +
                '<urn:salesOrderList soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
                '<sessionId xsi:type="xsd:string">' + SessionId + '</sessionId>' +
                '<filters xsi:type="urn:filters">' +
                '<complex_filter SOAP-ENC:arrayType="ns1:complexFilter[1]" xsi:type="ns1:complexFilterArray">' +
                '<item xsi:type="ns1:complexFilter">' +
                    '<key xsi:type="xsd:string">order_id</key>' +
                    '<value xsi:type="ns1:associativeEntity">' +
                    '<key xsi:type="xsd:string">gt</key>' +
                    '<value xsi:type="xsd:string">10</value>' +
                    '</value>' +
                '</item>' +
            '</complex_filter>' +
            '</filters>' +
            '</urn:salesOrderList>' +
            '</soapenv:Body>' +
            '</soapenv:Envelope>';

        HttpContent.Clear();
        HttpContent.WriteFrom(Payload);
        HttpContent.GetHeaders(HttpHeader);
        HttpHeader.Clear();
        HttpHeader.Add('Content-Type', 'text/xml;charset=UTF-8');
        HttpHeader.Add('Action', 'urn:Action');

        TextResponse := POST(HttpContent);

        XmlDocument.ReadFrom(TextResponse, OrderListXMLDoc);
        if OrderListXMLDoc.SelectNodes('//result/item', OrderListNode) then
            for i := 1 to OrderListNode.Count do begin
                OrderListNode.Get(i, OrderNode);
                TxtOrderNode := OrderNode.AsXmlElement().InnerXml();
                TxtOrderNode := StrSubstNo('%1%2%3', '<Items>', TxtOrderNode, '</Items>');

                IF XmlDocument.ReadFrom(TxtOrderNode, OrderXMLDoc) then begin
                    OrderXMLDoc.SelectSingleNode('//order_id', LineNode);
                    order_id := LineNode.AsXmlElement().InnerText();
                    If NOT OrderHdr.Get(order_id) then begin

                        OrderHdr.Init();
                        OrderHdr.order_id := order_id;

                        Clear(LineNode);
                        IF OrderXMLDoc.SelectSingleNode('//increment_id', LineNode) then
                            OrderHdr."Increment id" := LineNode.AsXmlElement().InnerText();

                        Clear(LineNode);
                        if OrderXMLDoc.SelectSingleNode('//store_id', LineNode) then
                            OrderHdr."store id" := LineNode.AsXmlElement().InnerText();

                        Clear(LineNode);
                        if OrderXMLDoc.SelectSingleNode('//created_at', LineNode) then
                            OrderHdr.created_at := LineNode.AsXmlElement().InnerText();

                        Clear(LineNode);
                        if OrderXMLDoc.SelectSingleNode('//store_name', LineNode) then
                            OrderHdr.store_name := LineNode.AsXmlElement().InnerText();

                        Clear(LineNode);
                        if OrderXMLDoc.SelectSingleNode('//status', LineNode) then
                            OrderHdr.status := LineNode.AsXmlElement().InnerText();

                        Clear(LineNode);
                        if OrderXMLDoc.SelectSingleNode('//state', LineNode) then
                            OrderHdr.state := LineNode.AsXmlElement().InnerText();

                        Clear(LineNode);
                        if OrderXMLDoc.SelectSingleNode('//global_currency_code', LineNode) then
                            OrderHdr.global_currency_code := LineNode.AsXmlElement().InnerText();

                        Clear(LineNode);
                        if OrderXMLDoc.SelectSingleNode('//firstname', LineNode) then
                            OrderHdr.firstname := LineNode.AsXmlElement().InnerText();

                        Clear(LineNode);
                        if OrderXMLDoc.SelectSingleNode('//lastname', LineNode) then
                            OrderHdr.firstname := LineNode.AsXmlElement().InnerText();

                        Clear(LineNode);
                        if OrderXMLDoc.SelectSingleNode('//customer_id', LineNode) then
                            OrderHdr.customer_id := LineNode.AsXmlElement().InnerText();

                        OrderHdr.Insert();


                    end;
                end;
            end;
    end;

    procedure GetOrderDetails(orderIncrementId: Code[50])
    var
        OrderLine: Record "Order Line";
        HttpHeader: HttpHeaders;
        HttpContent: HttpContent;
        Payload: Text;
        TextResponse: Text;

        OrderLineXMLDoc: XmlDocument;
        OrderLineListNode: XmlNodeList;
        SingleLineNode: XmlNode;
        TxtOrderLine: Text;
        LineXMLDoc: XmlDocument;
        LineNode: XmlNode;
        orderid: Code[50];
        i: Integer;

    begin
        Login();

        Payload :=
           '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:Magento">' +
               '<soapenv:Header/>' +
               '<soapenv:Body>' +
               '<urn:salesOrderInfo soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
                   '<sessionId xsi:type="xsd:string">' + SessionId + '</sessionId>' +
                   '<orderIncrementId xsi:type="xsd:string">' + orderIncrementId + '</orderIncrementId>' +
                   '</urn:salesOrderInfo>' +
               '</soapenv:Body>' +
           '</soapenv:Envelope>';

        HttpContent.Clear();
        HttpContent.WriteFrom(Payload);
        HttpContent.GetHeaders(HttpHeader);
        HttpHeader.Clear();
        HttpHeader.Add('Content-Type', 'text/xml;charset=UTF-8');
        HttpHeader.Add('Action', 'urn:Action');

        TextResponse := POST(HttpContent);


        XmlDocument.ReadFrom(TextResponse, OrderLineXMLDoc);
        if OrderLineXMLDoc.SelectNodes('//result/items', OrderLineListNode) then begin
            for i := 1 to OrderLineListNode.Count do begin
                OrderLineListNode.Get(i, SingleLineNode);
                TxtOrderLine := SingleLineNode.AsXmlElement().InnerXml();
                TxtOrderLine := StrSubstNo('%1%2%3', '<Items>', TxtOrderLine, '</Items>');

                IF XmlDocument.ReadFrom(TxtOrderLine, LineXMLDoc) then begin
                    LineXMLDoc.SelectSingleNode('//order_id', LineNode);
                    orderid := LineNode.AsXmlElement().InnerText();

                    OrderLine.Reset();
                    OrderLine.SetRange(order_id, orderid);
                    OrderLine.DeleteAll();

                    OrderLine.Init();
                    OrderLine.order_id := orderid;
                    OrderLine."Line No" := OrderLine.GetNextLineNo(orderid);

                    Clear(LineNode);
                    if LineXMLDoc.SelectSingleNode('//item_id', LineNode) then
                        OrderLine.item_id := LineNode.AsXmlElement().InnerText();

                    Clear(LineNode);
                    if LineXMLDoc.SelectSingleNode('//product_id', LineNode) then
                        OrderLine.product_id := LineNode.AsXmlElement().InnerText();

                    Clear(LineNode);
                    if LineXMLDoc.SelectSingleNode('//sku', LineNode) then
                        OrderLine.sku := LineNode.AsXmlElement().InnerText();

                    Clear(LineNode);
                    if LineXMLDoc.SelectSingleNode('//name', LineNode) then
                        OrderLine.name := LineNode.AsXmlElement().InnerText();

                    Clear(LineNode);
                    if LineXMLDoc.SelectSingleNode('//qty_ordered', LineNode) then
                        Evaluate(OrderLine.qty_ordered, LineNode.AsXmlElement().InnerText());

                    Clear(LineNode);
                    if LineXMLDoc.SelectSingleNode('//price', LineNode) then
                        Evaluate(OrderLine.price, LineNode.AsXmlElement().InnerText());

                    Clear(LineNode);
                    if LineXMLDoc.SelectSingleNode('//tax_amount', LineNode) then
                        Evaluate(OrderLine.tax_amount, LineNode.AsXmlElement().InnerText());

                    OrderLine.Insert();
                end;
            end;
        end;
    end;

    var

        MagentoSetup: Record "Magento Setup";
        SessionId: Text;

}