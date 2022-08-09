public with sharing class AccountBO {

    public static void CriarNovaTaskPorContaCriada(List<Account> contasDoGatilho){
        List<Task> novasTasks = new List<Task>();

        for(Account conta : contasDoGatilho){
            novasTasks.add(
                TaskBO.preencheTask(
                    'Ligar para ' + conta.Name, 
                    conta.Id, 
                    conta.OwnerId)
                );
        }

        insert novasTasks;
    }

    public static void FecharOportunidadesVencidas(List<Account> contasDoGatilho){
        Set<Id> idContas = new Set<Id>();
        for(Account conta : contasDoGatilho){
            idContas.add(conta.Id);
        }

        List<Opportunity> oportunidades = OpportunityDAO.BuscarPorIdConta(idContas);

        List<Opportunity> OportunidadesParaAtualizar = new List<Opportunity>();
        List<Task> novasTasks = new List<Task>();

        for(Opportunity opp : oportunidades){
            if(IsOportunidadeExpirada(opp)){

                opp.StageName = 'Closed Lost';
                OportunidadesParaAtualizar.add(opp);

                novasTasks.add(
                        TaskBO.preencheTask(
                            opp.Name, 
                            opp.AccountId, 
                            opp.OwnerId)
                    );
            }
        }

        update OportunidadesParaAtualizar;
        insert novasTasks;
    }

    public static void CriaContatoDaEmpresa(List<Account> contas){
        AtualizaContatoDaConta(
            contas, 
            CriaContatosRetornandoMapaContatoPorConta(contas)
        );
    }

    public static void CorrigeDominioDeEmailNosContatos(List<Account> contas, Map<Id,Account> contasAntigas){
        Map<Id,String> mapaIdPorDominio = new Map<Id,String>();
        Set<Id> IdDasContas = new Set<Id>();
        for(Account acc : contas){
            if(acc.dominio__c != contasAntigas.get(acc.Id).dominio__c){
                IdDasContas.add(acc.Id);
                mapaIdPorDominio.put(acc.Id, acc.dominio__c);
            }
        }

        if(!IdDasContas.isEmpty()){
            List<Contact> contatos = [SELECT email, AccountId FROM Contact WHERE AccountId in : IdDasContas];
            List<Contact> contatosParaAtualizar = new List<Contact>();
            for(Contact contato : contatos){
                
                if(String.isNotBlank(contato.email)){
                    List<String> partesDoEmail = contato.email.split('@');
                    if(partesDoEmail[1] !=  mapaIdPorDominio.get(contato.accountId)){
                        partesDoEmail[1] = mapaIdPorDominio.get(contato.accountId);
                        contato.email = String.join(partesDoEmail, '@'); 
                        contatosParaAtualizar.add(contato);
                    }
                }
            }

            update contatosParaAtualizar;
        }
    }



    private static Boolean IsOportunidadeExpirada(Opportunity Opp){
        Datetime hoje = Datetime.now();
        Datetime oppDate = (Opp.CloseDate).addDays(30);

        return oppDate < hoje && Opp.StageName != 'Closed Won';
    }

    private static Map<Id,Contact> CriaContatosRetornandoMapaContatoPorConta(List<Account> contas){
        List<Contact> contatosParaCriar = new List<Contact>();
        Map<Id,Contact> MapaContatoPorIdConta = new Map<Id,Contact>();

        for(Account conta : contas){
            Contact contatoDaEmpresa = new Contact();
            contatoDaEmpresa.LastName = conta.Name;
            contatoDaEmpresa.AccountId = conta.Id;
            contatosParaCriar.add(contatoDaEmpresa);
            MapaContatoPorIdConta.put(conta.Id,contatoDaEmpresa);
        }

        insert contatosParaCriar;

        return MapaContatoPorIdConta;
    }

    private static void AtualizaContatoDaConta(List<Account> contas, Map<Id,Contact> MapaContatoPorIdConta){
        List<Account> contasAtualizadas = new List<Account>();
        for(Account conta : contas){
            Account acc = new Account();
            acc.ContatoDaConta__c = MapaContatoPorIdConta.get(conta.Id).Id;
            acc.Id = MapaContatoPorIdConta.get(conta.Id).AccountId;
            contasAtualizadas.add(acc);
        }
        
        update contasAtualizadas;
    }
}
