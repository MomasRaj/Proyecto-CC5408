class_name BarraSalud extends ProgressBar

func actualizar_barra(maximo: float, actual: float):
	self.value = actual / maximo
