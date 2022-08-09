trigger OpportunityTrigger on Opportunity (before insert, after insert) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            OpportunityBO.PreenchePrincebook(Trigger.new);
        }
        when AFTER_INSERT {
            OpportunityBO.CriaProdutoDaOportunidade(Trigger.new);
        }
    }
}