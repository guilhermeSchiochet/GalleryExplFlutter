import 'package:flutter/material.dart';
import 'package:gallery_expl/src/utils/resources/list_images.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

// ScrollProgressProvider é uma classe que implementa ChangeNotifier.
// Ele gerencia o progresso da rolagem.
class ScrollProgressProvider with ChangeNotifier {
  double _progress = 0;
  
  // Getter para o progresso
  double get progress => _progress;

  // Método para atualizar o progresso
  void updateProgress(double newProgress) {
    _progress = newProgress;
    // Quando o progresso é atualizado, notificamos todos os ouvintes.
    notifyListeners();
  }
}

// HomeScreen é um StatelessWidget que retorna um ChangeNotifierProvider.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider cria uma instância de ScrollProgressProvider
    // e o torna disponível para _HomeScreen e seus widgets descendentes.
    return ChangeNotifierProvider(
      create: (context) => ScrollProgressProvider(),
      child: _HomeScreen(),
    );
  }
}

// _HomeScreen é um StatefulWidget que usa ScrollProgressProvider.
// Ele tem um estado que muda ao longo do tempo (a imagem selecionada e o controle de rolagem).
class _HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<String> _itens = ListItens.itens;


  String selectedImage = '';

  @override
  void initState() {
    super.initState();
    selectedImage = _itens.first;
    _scrollController.addListener(_updateScrollProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  // Update the scroll progress
  void _updateScrollProgress() {
    var provider = Provider.of<ScrollProgressProvider>(context, listen: false);
    provider.updateProgress(_scrollController.offset / _scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildPhotoView(),
        _buildImageList(),
      ],
    );
  }

  Widget _buildPhotoView() {
    return Expanded(
      flex: 10,
      child: PhotoView(
        imageProvider: AssetImage(selectedImage),
        initialScale: 1.0,
        basePosition: Alignment.center,
        minScale: PhotoViewComputedScale.contained * 1.0,
        maxScale: PhotoViewComputedScale.contained * 1.0,
        backgroundDecoration: const BoxDecoration(
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildImageList() {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, left: 10.0, bottom: 15),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade100),
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey.shade100,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade500.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
              ),
            ]
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  cacheExtent: 500.0,
                  children: _buildImageWidgets(),
                ),
              ),
              _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Consumer<ScrollProgressProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 20.0, right: 20.0),
          child: Align(
            alignment: Alignment((provider.progress * 2) - 1, 0),
            child: Material(
              elevation: 1.5,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 100,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildImageWidgets() {
    return _itens.map((item) {
      if(item.endsWith('.pdf')) {
        item = 'assets/images/image_pdf.png';
      }

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedImage = item;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: selectedImage == item ? Colors.orange.shade700 : Colors.transparent,
                width: 2
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                item,
                width: 120,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
