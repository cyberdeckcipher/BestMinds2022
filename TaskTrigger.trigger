trigger TaskTrigger on Task (after insert, before update, after update, after undelete) {

    if(Trigger.isAfter){
        if(trigger.isInsert){
            TaskBO.CriaOportunidadeAoCriarTask(Trigger.new);
        }
        if(trigger.isUpdate){
            TaskBO.MarcaContaComoContactada(Trigger.new, trigger.oldMap);
        }
    }
    
}