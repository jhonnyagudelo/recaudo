CREATE OR REPLACE FUNCTION  trigger_shift_expense()  RETURNS TRIGGER AS $$

DECLARE
   horario_salida TIME;
   numturno INT;
   bus INT;
BEGIN
   numturno:=(SELECT MAX(id_turno)FROM turno);
   bus:=(SELECT vehiculo FROM turno WHERE id_turno = numturno);


 END;
 $$ LANGUAGE plpgsql;
