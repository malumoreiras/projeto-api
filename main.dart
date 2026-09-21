
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Localizacao(),
  ));
}

// Tela que pode ser atualizada
class Localizacao extends StatefulWidget {
  const Localizacao({super.key});

  @override
  State<Localizacao> createState() => _LocalizacaoState();
}

class _LocalizacaoState extends State<Localizacao> {

  // Variáveis que exibem os dados na tela
  String latitude = 'Aguardando...';
  String longitude = 'Aguardando...';

  // Função que busca a localização atual
  Future<void> buscarLocalizacao() async {

    // Solicita permissão para acessar a localização
    LocationPermission permissao =
        await Geolocator.requestPermission();

    // Verifica se a permissão foi negada
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {

      // Atualiza os textos da tela
      setState(() {
        latitude = 'Permissão negada';
        longitude = 'Permissão negada';
      });

      // Encerra a função
      return;
    }

    // Busca a posição atual do dispositivo
    Position posicao =
        await Geolocator.getCurrentPosition();

    // Atualiza a tela com os dados recebidos
    setState(() {
      latitude = posicao.latitude.toString();
      longitude = posicao.longitude.toString();
    });
  }

  // Constrói a interface do aplicativo
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // Barra superior da tela
      appBar: AppBar(
        title: const Text('Minha Localização'),
      ),

      // Conteúdo principal
      body: Center(
        child: Column(

          // Centraliza os elementos verticalmente
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            // Exibe a latitude
            Text('Latitude: $latitude'),

            // Exibe a longitude
            Text('Longitude: $longitude'),

            // Espaço entre os textos e o botão
            const SizedBox(height: 20),

            // Botão que busca a localização
            ElevatedButton(
              onPressed: buscarLocalizacao,
              child: const Text('Obter Localização'),
            ),
          ],
        ),
      ),
    );
  }
}