public with sharing class OpportunityBO {

    public static void PreenchePrincebook (List<Opportunity> oportunidades){
        Pricebook2 priceBook = [SELECT Id FROM Pricebook2 LIMIT 1];
        for(Opportunity opp : oportunidades){
            opp.Pricebook2Id = priceBook.Id;
        }
    }

    public static void CriaProdutoDaOportunidade(List<Opportunity> oportunidades){
        List<OpportunityLineItem> produtosDaOportunidade = new List<OpportunityLineItem>();

        Set<Id> pricebooks = new Set<Id>();
        for(Opportunity opp : oportunidades){
            pricebooks.add(opp.Pricebook2Id);
        }

        List<PriceBookEntry> PricebookEntries = [SELECT Id, Pricebook2Id  FROM PricebookEntry WHERE Pricebook2Id in :pricebooks];
        Map<Id,PriceBookEntry> priceEntryPorPriceBook = new Map<Id,PriceBookEntry>();
        for(PricebookEntry entry : PricebookEntries){
            priceEntryPorPriceBook.put(entry.Pricebook2Id, entry);
        }

        for(Opportunity opp : oportunidades){
            OpportunityLineItem novoproduto = new OpportunityLineItem();

            novoproduto.PricebookEntryId = priceEntryPorPriceBook.get(opp.Pricebook2Id).Id;
            novoproduto.OpportunityId = opp.Id;
            novoproduto.Quantity = 1;
            novoproduto.UnitPrice = 1;

            produtosDaOportunidade.add(novoproduto);
        }

        insert produtosDaOportunidade;
    }
}
