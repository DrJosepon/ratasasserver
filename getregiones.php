<?php
  
  include 'conexion.php';
   
$format = $_GET['format'];
$sql = "  select * from region";
 header("Access-Control-Allow-Origin: *");
//$sql = "exec USP_Usuario_Login '$codigo', '$clave'";

try {
	//$Variable_Conexion = odbc_connect("Driver={SQL Server Native Client 11.0};Server=localhost;Database=RATASAS;", "ratas", "feed");
	$consulta = odbc_exec($Variable_Conexion, $sql);
	$response = array();
	/*
	while ($datos = odbc_fetch_object($consulta)) {
		array_push($response, $datos);
	}*/
	
	if(odbc_num_rows($consulta)) {
		while($post = odbc_fetch_array($consulta)) {
			$response[] = array('post'=>utf8_converter($post));
		}
	}
	
	//echo '{"items":' . json_encode($response) . '}';
} catch(PDOException $e) {
	echo '{"error":{"text":' . $e -> getMessage() . '}}';
}

function utf8_converter($array) {
	array_walk_recursive($array, function(&$item, $key) {
		if (!mb_detect_encoding($item, 'utf-8', true)) {
			$item = utf8_encode($item);
		}
	});
	return $array;
}

if($format == 'json') {
		header('Content-type: application/json');
		echo json_encode(array('items'=>$response));

	}
	else {
		header('Content-type: text/xml');
		echo '<items>';
		foreach($response as $index => $post) {
			if(is_array($post)) {
				foreach($post as $key => $value) {
					echo '<',$key,'>';
					if(is_array($value)) {
						foreach($value as $tag => $val) {
							echo '<',$tag,'>',$val,'</',$tag,'>';
						}
					}
					echo '</',$key,'>';
				}
			}
		}
		echo '</items>';
	}



?>