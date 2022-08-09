public with sharing class OpportunityDAO {

    public static List<Opportunity> BuscarPorIdConta(Set<Id> Idcontas){
        return [
            SELECT 
                Name,
                CloseDate, 
                StageName 
            FROM Opportunity 
            WHERE Id in :idContas
        ];
    }

}
