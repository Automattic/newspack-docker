<?php 
add_action(
	'phpmailer_init',
	function ($phpmailer) {
		$phpmailer->Host='mailhog';
		$phpmailer->Port=1025;
		$phpmailer->SMTPAuth=false;
		$phpmailer->IsSMTP();
	}
);

