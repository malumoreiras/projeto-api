import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<CameraDescription> cameras = [];

  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Erro ao encontrar câmeras: $e');
  }

  runApp(
    MeuAplicativo(
      cameras: cameras,
    ),
  );
}

const Color azulPrincipal = Color(0xFF1E88E5);
const Color fundo = Color(0xFFF5F5F5);

class MeuAplicativo extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MeuAplicativo({
    super.key,
    required this.cameras,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'API',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: azulPrincipal,
        ),
        scaffoldBackgroundColor: fundo,

        appBarTheme: const AppBarTheme(
          backgroundColor: azulPrincipal,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      home: MenuPrincipal(
        cameras: cameras,
      ),
    );
  }
}

class MenuPrincipal extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MenuPrincipal({
    super.key,
    required this.cameras,
  });

  @override
  State<MenuPrincipal> createState() =>
      _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  int indiceAtual = 0;

  @override
  Widget build(BuildContext context) {
    final telas = [
      const Feed(),
      const Cnpj(),
      const Localizacao(),
      CameraApp(
        cameras: widget.cameras,
      ),
    ];

    return Scaffold(
      body: telas[indiceAtual],

      bottomNavigationBar: NavigationBar(
        selectedIndex: indiceAtual,

        onDestinationSelected: (index) {
          setState(() {
            indiceAtual = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed),
            label: 'Feed',
          ),

          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'CNPJ',
          ),

          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Localização',
          ),

          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Câmera',
          ),
        ],
      ),
    );
  }
}

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final fotos = [
    'https://images.unsplash.com/photo-1470770841072-f978cf4d019e?w=600',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=600',
    'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=600',
  ];

  final curtidas = [12, 25, 8];
  final gostei = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Feed')),
      body: ListView.builder(
        itemCount: fotos.length,
        itemBuilder: (context, i) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('Aluno do curso'),
            ),
            Image.network(
              fotos[i],
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    gostei[i] ? Icons.favorite : Icons.favorite_border,
                    color: gostei[i] ? Colors.red : null,
                  ),
                  onPressed: () => setState(() {
                    gostei[i] = !gostei[i];
                    curtidas[i] += gostei[i] ? 1 : -1;
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Botão comentar')),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Botão compartilhar')),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('${curtidas[i]} curtidas'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class Cnpj extends StatefulWidget {
  const Cnpj({
    super.key,
  });

  @override
  State<Cnpj> createState() => _CnpjState();
}

class _CnpjState extends State<Cnpj> {
  final TextEditingController cnpj =
      TextEditingController();

  String empresa = '';
  bool carregando = false;

  Future<void> consultar() async {
    if (cnpj.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um CNPJ.'),
        ),
      );
      return;
    }

    setState(() {
      carregando = true;
    });

    final url = Uri.parse(
      'https://api.opencnpj.org/${cnpj.text}',
    );

    try {
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        setState(() {
          empresa =
              'Razão Social: ${dados['razao_social'] ?? 'N/A'}\n'
              'Nome Fantasia: ${dados['nome_fantasia'] ?? 'N/A'}\n'
              'CNPJ: ${dados['cnpj'] ?? ''}\n'
              'Situação: ${dados['situacao_cadastral'] ?? ''}\n'
              'Endereço: ${dados['logradouro'] ?? ''}, '
              '${dados['numero'] ?? ''}\n'
              '${dados['bairro'] ?? ''} - '
              '${dados['municipio'] ?? ''}/'
              '${dados['uf'] ?? ''}';
        });
      } else {
        setState(() {
          empresa = 'Erro ao consultar o CNPJ.';
        });
      }
    } catch (e) {
      setState(() {
        empresa =
            'Falha na conexão ou CNPJ inválido.';
      });
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  @override
  void dispose() {
    cnpj.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta CNPJ'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.business,
              size: 90,
              color: azulPrincipal,
            ),

            const SizedBox(height: 20),

            const Text(
              'Consulta de Empresa',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: cnpj,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(
                labelText: 'CNPJ',
                prefixIcon:
                    Icon(Icons.business),
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed:
                    carregando ? null : consultar,

                icon: const Icon(Icons.search),

                label: Text(
                  carregando
                      ? 'Consultando...'
                      : 'Consultar',
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (empresa.isNotEmpty)
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Text(
                    empresa,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Localizacao extends StatefulWidget {
  const Localizacao({
    super.key,
  });

  @override
  State<Localizacao> createState() =>
      _LocalizacaoState();
}

class _LocalizacaoState
    extends State<Localizacao> {

  String latitude = 'Aguardando...';
  String longitude = 'Aguardando...';

  bool carregando = false;

  Future<void> buscarLocalizacao() async {
    setState(() {
      carregando = true;
    });

    LocationPermission permissao =
        await Geolocator.checkPermission();

    if (permissao ==
        LocationPermission.denied) {
      permissao =
          await Geolocator.requestPermission();
    }

    if (permissao ==
            LocationPermission.denied ||
        permissao ==
            LocationPermission.deniedForever) {
      setState(() {
        latitude = 'Permissão negada';
        longitude = 'Permissão negada';
        carregando = false;
      });

      return;
    }

    try {
      Position posicao =
          await Geolocator
              .getCurrentPosition();

      setState(() {
        latitude =
            posicao.latitude.toString();

        longitude =
            posicao.longitude.toString();

        carregando = false;
      });
    } catch (e) {
      setState(() {
        latitude = 'Erro';
        longitude = 'Erro';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('GPS / Localização'),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.location_on,
                size: 90,
                color: azulPrincipal,
              ),

              const SizedBox(height: 25),

              Text(
                'Latitude:\n$latitude',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(height: 15),

              Text(
                'Longitude:\n$longitude',
                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(height: 25),

              ElevatedButton.icon(
                onPressed:
                    carregando
                        ? null
                        : buscarLocalizacao,

                icon: const Icon(
                  Icons.my_location,
                ),

                label: Text(
                  carregando
                      ? 'Obtendo...'
                      : 'Obter Localização',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraApp({
    super.key,
    required this.cameras,
  });

  @override
  State<CameraApp> createState() =>
      _CameraAppState();
}

class _CameraAppState
    extends State<CameraApp> {

  CameraController? camera;

  XFile? foto;

  bool inicializando = true;

  String? erro;

  @override
  void initState() {
    super.initState();

    iniciarCamera();
  }

  Future<void> iniciarCamera() async {
    setState(() {
      inicializando = true;
      erro = null;
    });

    if (widget.cameras.isEmpty) {
      setState(() {
        inicializando = false;

        erro =
            'Nenhuma câmera foi encontrada.\n\n'
            'Se você está usando o PC, '
            'execute o aplicativo pelo Chrome '
            'com "flutter run -d chrome".';
      });

      return;
    }

    try {
      camera?.dispose();

      camera = CameraController(
        widget.cameras.first,

        ResolutionPreset.medium,

        enableAudio: false,
      );

      await camera!.initialize();

      if (!mounted) return;

      setState(() {
        inicializando = false;
      });
    } on CameraException catch (e) {
      if (!mounted) return;

      setState(() {
        inicializando = false;

        erro =
            'Erro ao acessar a câmera.\n\n'
            'Código: ${e.code}\n'
            'Mensagem: ${e.description ?? ''}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        inicializando = false;

        erro =
            'Não foi possível iniciar a câmera.\n\n$e';
      });
    }
  }

  Future<void> tirarFoto() async {
    if (camera == null ||
        !camera!.value.isInitialized) {
      return;
    }

    try {
      foto = await camera!.takePicture();

      setState(() {});
    } on CameraException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao tirar foto: ${e.description ?? e.code}',
          ),
        ),
      );
    }
  }

  Future<void> abrirCamera() async {
    setState(() {
      foto = null;
    });

    await iniciarCamera();
  }


  Future<void> galeria() async {
    try {
      final XFile? imagem =
          await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (imagem != null) {
        setState(() {
          foto = imagem;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao abrir a galeria: $e',
          ),
        ),
      );
    }
  }
  @override
  void dispose() {
    camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (inicializando) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Câmera'),
        ),

        body: const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (erro != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Câmera'),
        ),

        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                const Icon(
                  Icons.camera_alt,
                  size: 80,
                  color: Colors.grey,
                ),

                const SizedBox(height: 25),

                Text(
                  erro!,
                  textAlign:
                      TextAlign.center,

                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton.icon(
                  onPressed:
                      iniciarCamera,

                  icon: const Icon(
                    Icons.refresh,
                  ),

                  label: const Text(
                    'Tentar novamente',
                  ),
                ),

                const SizedBox(height: 15),

                OutlinedButton.icon(
                  onPressed: galeria,

                  icon: const Icon(
                    Icons.photo,
                  ),

                  label: const Text(
                    'Abrir Galeria',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Câmera'),
      ),

      body: Column(
        children: [

          Expanded(
            child: foto == null
                ? CameraPreview(camera!)
                : FutureBuilder(
                    future:
                        foto!.readAsBytes(),

                    builder:
                        (_, imagem) {

                      if (!imagem.hasData) {
                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      return Image.memory(
                        imagem.data!,
                        fit:
                            BoxFit.contain,
                      );
                    },
                  ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              // CÂMERA / NOVA FOTO
              FloatingActionButton(
                heroTag:
                    'cameraButton',

                onPressed:
                    foto == null
                        ? tirarFoto
                        : abrirCamera,

                child: Icon(
                  foto == null
                      ? Icons.camera_alt
                      : Icons.camera,
                ),
              ),

              const SizedBox(width: 30),

              // GALERIA
              FloatingActionButton(
                heroTag:
                    'galleryButton',

                onPressed:
                    galeria,

                child: const Icon(
                  Icons.photo,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}