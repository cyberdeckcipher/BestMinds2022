trigger AccountTrigger on Account (after insert, after update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            List<Task> novasTasks = new List<Task>();
            for(Account conta : Trigger.new){
                Task novaTask = new Task();

                novaTask.Description = 'contactar '+ conta.Name;
                novaTask.Subject = 'Call';
                novaTask.Status = 'Not Started';
                novaTask.Priority = 'Normal';

                novaTask.WhatId = conta.Id;
                novaTask.OwnerId = conta.OwnerId;

                novasTasks.add(novaTask);
            }

            insert novasTasks;
        }

        if(Trigger.isUpdate){
            Set<Id> idContas = new Set<Id>();
            for(Account conta : Trigger.new){
                idContas.add(conta.Id);
            }

            List<Opportunity> oportunidades = [SELECT CreatedDate, StageName FROM Opportunity WHERE Id in :idContas];
            List<Opportunity> OportunidadesParaAtualizar = new List<Opportunity>();
            List<Task> novasTasks = new List<Task>();

            for(Opportunity opp : oportunidades){
                Datetime hoje = Datetime.now();
                Datetime oppDate = (Opp.CreatedDate).addDays(30);
                if(oppDate < hoje && Opp.StageName != 'Closed Won'){
                    opp.StageName = 'Closed Lost';
                    OportunidadesParaAtualizar.add(opp);

                    Task novaTask = new Task();

                    novaTask.WhatId = opp.AccountId;
                    novaTask.OwnerId = opp.OwnerId;

                    novasTasks.add(novaTask);
                }
            }

            update OportunidadesParaAtualizar;
            insert novasTasks;
        }
    }
}