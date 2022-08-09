public with sharing class OpportunityLineItemBO {


    public static void CriaTaskParaOportunidadesComValoresAltos(
        List<OpportunityLineItem> produtosDaOportunidade, 
        Map<Id,OpportunityLineItem> MapaProdutosNovos, 
        Map<Id,OpportunityLineItem> MapaProdutosAntigos){

        Set<Id> IdDeOportunidades = new Set<Id>();
        for(OpportunityLineItem item : produtosDaOportunidade){
            IdDeOportunidades.add(item.OpportunityId);
        }
        List<Opportunity> oportunidadesAtingidas = [SELECT Id, StageName
                                                    FROM Opportunity 
                                                    WHERE Id IN : IdDeOportunidades];
        
        Set<Id> oportunidadesAbertas = new Set<Id>();
        for(Opportunity opp : oportunidadesAtingidas){
            if(opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost'){
                oportunidadesAbertas.add(opp.Id);
            }
        }

        List<Opportunity> oportunidadesEmAberto = new List<Opportunity>();
        for(Opportunity opp : oportunidadesAtingidas){
            if(oportunidadesAbertas.contains(opp.id)){
                oportunidadesEmAberto.add(opp);
            }
        }

        List<OpportunityLineItem> produtosDasOportunidades = [SELECT Id 
                                                            FROM OpportunityLineItem 
                                                            WHERE OpportunityId IN :oportunidadesAbertas];

        Map<Id,List<OpportunityLineItem>> MapaIdOppotunityPorProdutos = new Map<Id,List<OpportunityLineItem>>();
        for(OpportunityLineItem item : produtosDasOportunidades){
            List<OpportunityLineItem> itensDaOportunidade = new List<OpportunityLineItem>();
            if(MapaIdOppotunityPorProdutos.containsKey(item.OpportunityId)){
                itensDaOportunidade = MapaIdOppotunityPorProdutos.get(item.OpportunityId);
            }
            itensDaOportunidade.add(item);
            MapaIdOppotunityPorProdutos.put(item.OpportunityId, itensDaOportunidade);
        }
        List<Task> tasksParaInserir = new List<Task>();
        for(Opportunity opp : oportunidadesEmAberto){
            List<OpportunityLineItem> itensDaOportunidade = MapaIdOppotunityPorProdutos.get(opp.Id);
            Double valorAtual = 0;
            Double valorAntigo = 0;
            for(OpportunityLineItem item : itensDaOportunidade){
                if(MapaProdutosAntigos.containsKey(item.Id)){
                    valorAntigo += MapaProdutosAntigos.get(item.Id).TotalPrice;
                    valorAtual += MapaProdutosNovos.get(Item.Id).TotalPrice;
                }{
                    valorAtual += item.TotalPrice;
                    valorAntigo += item.TotalPrice;
                }
            }
            if(valorAtual > 100000 && valorAntigo < 100000){
                tasksParaInserir.add(
                        TaskBO.preencheTask(
                            'Validar valor alto', 
                            'Email', 
                            'Not Started', 
                            'High',
                            Opp.Id,
                            Opp.OwnerId
                        )
                    );
            }
        }

    }
}
