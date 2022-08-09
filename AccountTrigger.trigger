trigger AccountTrigger on Account (after insert, after update) {

    switch on Trigger.operationType {

        when AFTER_INSERT {
            AccountBO.CriarNovaTaskPorContaCriada(Trigger.new);
            AccountBO.CriaContatoDaEmpresa(Trigger.new);
        }

        when AFTER_UPDATE {
            AccountBO.FecharOportunidadesVencidas(Trigger.New);
            AccountBO.CorrigeDominioDeEmailNosContatos(Trigger.new, Trigger.oldMap);
        }
    }
}