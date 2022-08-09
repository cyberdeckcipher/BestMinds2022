public with sharing class TaskBO {
    
    public static void MarcaContaComoContactada(List<Task> tasks, Map<Id,task> MapOldTasks){
        List<Task> tasksConcluidas = new List<Task>();
        
        System.debug('Gatilho foi executado');

        for(Task tasknova : tasks){

            Task taskAntiga = MapOldTasks.get(tasknova.Id);

            System.debug('task nova:' + tasknova);
            System.debug('task antiga:' + taskAntiga);

            if(tasknova.status == 'Completed' && tasknova.Status != taskAntiga.Status){
                tasksConcluidas.add(tasknova);
            }
        }
        
        if(!tasksConcluidas.isEmpty()){
            Set<Id> idsDasContas = new Set<Id>();
            
            for(Task taskconcluida : tasksConcluidas){
                idsDasContas.add(taskconcluida.AccountId);
            }
            
            List<Account> ContasDasTasks = [SELECT ContactadaPorFuncionario__c 
                                                FROM Account 
                                                WHERE Id in :idsDasContas];

            List<Account> contasParaAtualizar = new List<Account>();

            for(Account conta : ContasDasTasks){
                if(!conta.ContactadaPorFuncionario__c){

                    conta.ContactadaPorFuncionario__c = true;
                    contasParaAtualizar.add(conta);
                    System.debug('Uma conta vai ser atualizada.');
                }
            }
            
            If(!contasParaAtualizar.isEmpty()){
                update contasParaAtualizar;
            }
        }
    }

    public static void CriaOportunidadeAoCriarTask(List<Task> tasks){
        Set<Id> setIds = new Set<Id>();
        for(Task t : tasks){
            setIds.add(t.AccountId);
        }

        List<Account> contas = [SELECT Name FROM Account WHERE Id IN : setIds];
        Map<Id,String> MapContaPorId = new Map<Id,String>();
        for(Account conta : contas){
            MapContaPorId.put(conta.Id, conta.Name);
        }
        List<Opportunity> opportunidades = new List<Opportunity>();
        for(Task t : tasks){
            Opportunity opp = new Opportunity();
            opp.Name = MapContaPorId.get(t.AccountId);
            opp.AccountId = t.AccountId;
            opp.CloseDate = (Date.today()).addDays(30);
            opp.StageName = 'Prospecting';
            opp.Type = 'New Customer';

            opportunidades.add(opp);
        }

        insert opportunidades;


        List<Task> tasksParaInserir = new List<Task>();
        for(Opportunity opp : opportunidades){

            Task novaTask = preencheTask(
                'Oportunidade com mais de 30 dias', 
                opp.AccountId, 
                opp.OwnerId);

            tasksParaInserir.add(novaTask);
        }

        insert tasksParaInserir;
    }
 
    public static Task preencheTask(String descricao, Id whatId, Id owner){
        return preencheTask(
            descricao, 
            'Call', 
            'Not Started', 
            'Normal', 
            whatId, 
            owner);
    }

    public static Task preencheTask(String descricao, string subject, string status, string priority, Id whatId, Id owner){
        Task novaTask = new Task();

        novaTask.Description = descricao;
        novaTask.Subject = subject;
        novaTask.Status = status;
        novaTask.Priority = priority;

        novaTask.WhatId = whatId;
        novaTask.OwnerId = owner;

        return novaTask;
    }
}
