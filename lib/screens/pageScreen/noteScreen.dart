import 'dart:async';

import 'package:ebarge/models/filter.dart';
import 'package:ebarge/models/noteModel.dart';
import 'package:ebarge/models/pageModel.dart';
import 'package:ebarge/services/GlobalKeys.dart';
import 'package:ebarge/services/accessCheck.dart';
import 'package:ebarge/services/notes_service.dart' show CommandHandler, NoteCommand;
import 'package:ebarge/providers/userProvider.dart';
import 'package:ebarge/utils/utils.dart';
import 'package:ebarge/widgets/note/NoteDrawer.dart';
import 'package:ebarge/widgets/note/notes_grid.dart';
import 'package:ebarge/widgets/note/notes_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:tuple/tuple.dart';

import '../../styles.dart';


/// Home screen, displays [Note] grid or list.
class NoteScreen extends StatefulWidget {
  pageModel _pageData;
  NoteScreen(this._pageData);

  @override
  State<StatefulWidget> createState() => _NoteScreenState(this._pageData);
}

/// [State] of [NoteScreen].
class _NoteScreenState extends State<NoteScreen> with CommandHandler{
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  pageModel _pageData;
  _NoteScreenState(this._pageData);

  /// `true` to show notes in a GridView, a ListView otherwise.
  bool _gridView = false;
  int? _reload;
  NoteModel? uNote;
  NoteFilter? myFilter = NoteFilter();
  List<NoteModel>? uNotes;
  bool _firstView = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_reload = 0;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    //get the state, check current User, set AuthStatus based on state
    bool isAccess = await AccessCheck().hasAccessTime();
    if(!isAccess){
      UserProvider userProvider = UserProvider.instance();
      await userProvider.onStartUp();
    }
   // if(_reload == 1) {
      // Timer(Duration(seconds: 2), () {
      //   setState(() {
      //     _isImageReady = true;
      //   });
      // });
      setState(() {
        //_reload = 0;
      });
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
//      statusBarColor: Colors.white,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  NoteModel.instance(
                      _pageData.page_id, myFilter!, '',
                      Jalali.now().toDateTime()), /*NoteModel.instance(
                _pageData.page_id, , ),NoteModel(
              note_id: '',
              created_date:  Jalali.now().toDateTime(), page_id: '', state: NoteState.unspecified, title: '', color: null, error_description: '', status: '', thenote: '', saved_content_id: '', error_code: '', modified_date: null, user_id: '',
            ), */ // watching the note filter
            ),
            ChangeNotifierProvider(
              create: (_) => NoteFilter(), // watching the note filter
            ),
            Consumer<NoteFilter?>(
              builder: (context, filter, child) =>
                  FutureProvider.value(
                    value: _createNoteStream(context, filter!),
                    // applying the filter
                    initialData: [],
                    child: child,
                  ),
            ),
          ],
          child: Consumer2(
            builder: (context, NoteFilter filter, NoteModel noteProv, child) {
              // filter = NoteFilter();
              uNote = noteProv;
              List<NoteModel>? notes = noteProv.getPageNotes;
              final hasNotes = notes.isNotEmpty == true;
              final canCreate = filter.noteState.canCreate;
              return Scaffold(
                key: _scaffoldKey,
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(width: 720),
                    child: CustomScrollView(
                      slivers: <Widget>[
                        _appBar(context, filter, child != null
                            ? child
                            : Container()),
                        if (hasNotes) const SliverToBoxAdapter(
                          child: SizedBox(height: 24),
                        ),
                        ..._buildNotesView(context, filter, notes),
                        if (hasNotes) SliverToBoxAdapter(
                          child: SizedBox(
                              height: (canCreate ? kBottomBarSize : 10.0) +
                                  10.0),
                        ),
                      ],
                    ),
                  ),
                ),
                drawer: NoteDrawer(),
                floatingActionButton: canCreate ? _fab(context) : null,
                floatingActionButtonLocation: FloatingActionButtonLocation
                    .endDocked,
                extendBody: true,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _appBar(BuildContext context, NoteFilter filter, Widget bottom) =>
    filter.noteState < NoteState.archived
      ? SliverAppBar(
        floating: true,
        snap: true,
        title: _topActions(context),
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
      )
      : SliverAppBar(
        floating: true,
        snap: true,
        title: Text(filter.noteState.filterName),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black,),
          tooltip: 'منو',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        automaticallyImplyLeading: false,
      );

  Widget _topActions(BuildContext context) {
    String title ='یادداشت هایم برای صفحه'+AccessCheck().replaceFarsiNumber(_pageData.real_page_num!);
    return Container(
      // width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 720,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isNotAndroid ? 7 : 5),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 20),
              InkWell(
                child: const Icon(Icons.menu, color: Colors.black,),
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title,
                  softWrap: false,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                child: Icon(_gridView ? Icons.view_list : Icons.view_module, color: Colors.black,),
                onTap: () => setState(() {
                  _gridView = !_gridView;
                }),
              ),
              const SizedBox(width: 18),
              _buildAvatar(),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 15),
    child: FloatingActionButton(
      backgroundColor: Colors.pink,
      child: const Icon(Icons.add, color: Colors.white,),
      onPressed: () async {
        NoteModel emptyNote = NoteModel(note_id: '', page_id: '', user_id: '', saved_content_id: '', title: '', thenote: '', color: Colors.white, state: NoteState.unspecified, created_date: DateTime.now(), modified_date: DateTime.now(), status: '', error_code: '', error_description: '');
        final command = await Navigator. pushNamed(context, '/note', arguments: { 'note': emptyNote });
        debugPrint('--- noteEditor result: $command');
        processNoteCommand(_scaffoldKey.currentState!, command as NoteCommand);
      },
    ),
  );

  Widget _buildAvatar() {
    final url = GlobalKeys.ebargeUrl + '/'+_pageData.page_thumb!;
    return CircleAvatar(
      backgroundImage: NetworkImage(url),
      child: const Icon(Icons.face, color: Colors.black,),
      radius: isNotAndroid ? 19 : 17,
    );
  }

  /// A grid/list view to display notes
  ///
  /// Notes are divided to `Pinned` and `Others` when there's no filter,
  /// and a blank view will be rendered, if no note found.
  List<Widget> _buildNotesView(BuildContext context, NoteFilter filter, List<NoteModel>? notes) {
   // uNote = Provider.of<NoteModel>(context);
  /*  uNote!.noteStatus ==
        NoteStatus.Initializing ?
    _showLoadingTitle() :
    uNote!.noteStatus ==
        NoteStatus.Uninitialized ?
    _showCircularIndicator()
        : _buildBlankView(filter.noteState);*/

    if ( uNote!.noteStatus == NoteStatus.Initializing ) {
      return [_showLoadingTitle()];
     // return [_buildBlankView(filter.noteState)];
    } else if( uNote!.noteStatus == NoteStatus.Uninitialized ){
      return [_showCircularIndicator()];
    } else if(uNote!.noteStatus == NoteStatus.BlankNotes){
      return [_buildBlankView(filter.noteState)];
    }

    final asGrid = filter.noteState == NoteState.deleted || _gridView;
    final factory = asGrid ? NotesGrid.create : NotesList.create;
    final showPinned = filter.noteState == NoteState.unspecified;

    if (!showPinned) {
      return [
        factory(notes: notes!, onTap: _onNoteTap),
      ];
    }

    final partition = _partitionNotes(notes!);
    final hasPinned = partition.item1.isNotEmpty;
    final hasUnpinned = partition.item2.isNotEmpty;

    final _buildLabel = (String label, [double top = 26]) => SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsetsDirectional.only(start: 26, bottom: 25, top: top),
        child: Text(label, style: const TextStyle(
          color: kHintTextColorLight,
          fontWeight: FontWeights.medium,
          fontSize: 12),
        ),
      ),
    );

    return [
      if (hasPinned) _buildLabel('سنجاق شده', 0),
      if (hasPinned) factory(notes: partition.item1, onTap: _onNoteTap),
      if (hasPinned && hasUnpinned) _buildLabel('یادداشتها'),
      factory(notes: partition.item2, onTap: _onNoteTap),
    ];
  }

  Widget _buildBlankView(NoteState filteredState) => SliverFillRemaining(
    hasScrollBody: false,
    child: Container(
      padding: EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Expanded(flex: 1, child: SizedBox()),
          Icon(Icons.speaker_notes,
            size: 60,
            color: Colors.indigo,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          Expanded(
            flex: 2,
            child: Text(filteredState.emptyResultMessage,
              style: TextStyle(
                color: kHintTextColorLight,
                fontSize: 15,
                fontFamily: "Vazir"
              ),
            ),
          ),
        ],
      ),
    ),
  );


  _showLoadingTitle() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Expanded(flex: 1, child: SizedBox()),
          SpinKitFadingCube (
            color: Colors.indigo,
            size: 45.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
          ),
          Expanded(
            flex: 2,
            child: Text('در حال فراهم سازی یادداشت(ها)!',
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 15,
                  fontFamily: "Vazir"
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showCircularIndicator() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Expanded(flex: 1, child: SizedBox()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
              ),
            ],
          ),
          Expanded(
            flex: 2,
            child: Text('ارتباط اینترنتی برقرار نیست!',
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 15,
                  fontFamily: "Vazir"
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Callback on a single note clicked
  void _onNoteTap(NoteModel note) async {
    final command = await Navigator.pushNamed(context, '/note', arguments: { 'note': note });
    processNoteCommand(_scaffoldKey.currentState!, command as NoteCommand);
  }

  /// Create notes query
 Future<List<NoteModel>?> _createNoteStream(BuildContext context, NoteFilter filter) async{
    if(_firstView == false || filter.noteState != NoteState.unspecified) {
      List<NoteModel>? myNotes = await context.read<NoteModel>().fetchNotes(
          _pageData.page_id, filter);
      //setState(() {});
      //(context as Element).reassemble();
      return myNotes;
    }
    _firstView = false;
    return null;
  }

  /// Partition the note list by the pinned state
  Tuple2<List<NoteModel>, List<NoteModel>> _partitionNotes(List<NoteModel> notes) {
    if (notes.isNotEmpty != true) {
      return Tuple2([], []);
    }

    final indexUnpinned = notes.indexWhere((n) => !n.pinned);
    return indexUnpinned > -1
      ? Tuple2(notes.sublist(0, indexUnpinned), notes.sublist(indexUnpinned))
      : Tuple2(notes, []);
  }
}
