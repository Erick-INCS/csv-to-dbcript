# install.packages("dplyr")
library("dplyr")

setwd("~/Documents/Manif-valor/cats unicode-utf8/")

decrem <- read.csv("Decrementables-Table 1.csv")
formaPago <- read.csv("Formas de pago-Table 1.csv")
increm <- read.csv("Incrementables-Table 1.csv")
valoracion <- read.csv("Métodos de Valoración-Table 1.csv")

formaPago <- select(formaPago, CLAVE:DESCRIPCIÓN)
increm <- select(increm, CLAVE:DESCRIPCIÓN)
valoracion <- select(valoracion, CLAVE:DESCRIPCIÓN)

save <- function(dt, table, file, valueField='VALUE', descField='DESCRIPCION', useExtra='') {
    sqls <- apply(dt, 1, function(data) {
        sprintf(
            "INSERT INTO %s(%s, %s) VALUES ('%s', '%s');", 
            table, valueField, descField, data[1], substring(data[2], 0, 250)
        )
    })

    write(
        c(
            "SET TERM !! ;",
            "EXECUTE BLOCK AS BEGIN",
            sprintf("if (not exists(select 1 from rdb$relations where rdb$relation_name = '%s')) then", table),
            sprintf("execute statement 'create table %s ( %s VARCHAR(20), %s VARCHAR(250), constraint pk_%s_%s PRIMARY KEY(%s) %s );';", table, valueField, descField, table, valueField, valueField, useExtra),
            "END!!",
            "SET TERM ; !!",
            "",
            paste(sqls, collapse='')
        ),
        file
    )
}

save(decrem, 'MANIFVALOR_DECREM', 'MANIFVALOR_DECREM.sql', 'MVD_CLAVE', 'MVD_DESCRIPCION')
save(formaPago, 'MANIFVALOR_FORMAPAGO', 'MANIFVALOR_FORMAPAGO.sql', 'MVF_CLAVE', 'MVF_DESCRIPCION')
save(increm, 'MANIFVALOR_INCREM', 'MANIFVALOR_INCREM.sql', 'MVI_CLAVE', 'MVI_DESCRIPCION')
save(valoracion, 'MANIFVALOR_VAL', 'MANIFVALOR_VAL.sql', 'MVV_CLAVE', 'MVV_DESCRIPCION')