import 'package:flutter/material.dart';
import 'package:jshadowing_app/screens/providers/conversation_provider.dart';
import 'package:jshadowing_app/widgets/furigana_text.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    required this.unitId,
    required this.sectionId,
    super.key,
  });

  final int unitId;
  final int sectionId;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ConversationProvider>();
      await provider.loadConversationData();
      final section = provider.getSection(widget.unitId, widget.sectionId);

      if (section != null) {
        provider.initAudio(widget.unitId, widget.sectionId, section.audioAsset);
      }
    });
  }

  void _scrollToActiveBubble(int index) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        alignment: 0.5, // 0.5 tells the framework to perfectly center the targeted index row item
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<ConversationProvider>().stopAndResetAudio();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            'Unit - ${widget.unitId} | Section - ${widget.sectionId}',
          ),
        ),
        body: Consumer<ConversationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(child: const CircularProgressIndicator());
            }
            if (provider.errorMessage != null) {
              return Center(child: Text(provider.errorMessage.toString()));
            }

            final targetSection = provider.getSection(
              widget.unitId,
              widget.sectionId,
            );
            if (targetSection == null) {
              return Center(child: Text('Conversation data not found'));
            }
            final dialogues = targetSection.dialogues;
            final activeIndex = provider.activeDialogueIndex;
            if (activeIndex != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToActiveBubble(activeIndex);
              });
            }

            return Column(
              children: [
                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    padding: .all(12),
                    itemCount: dialogues.length,
                    itemBuilder: (context, index) {
                      final dialogue = dialogues[index];
                      // final bool isActive =
                      //     provider.activeDialogueIndex == index;
                      final bool isActive = activeIndex == index;

                      return GestureDetector(
                        onTap: () =>
                            provider.playDialogueSegment(dialogue.startMs),
                        child: Padding(
                          padding: .only(bottom: 20),
                          child: _buildAvatarAndSpeech(
                            dialogue.speaker,
                            dialogue.japanese,
                            dialogue.furigana,
                            dialogue.myanmar,
                            isActive,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildAudioBottomBar(provider.audioPlayer),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarAndSpeech(
    String speaker,
    String speech,
    String furigana,
    String myanmar,
    bool isActive,
  ) {
    final bool speakerA = speaker == 'A';

    return Row(
      mainAxisAlignment: speakerA
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (speakerA) ...[
          CircleAvatar(
            backgroundColor: Colors.amberAccent,
            child: Text(
              speaker,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(12),
            margin: speakerA
                ? const EdgeInsets.only(right: 40)
                : const EdgeInsets.only(left: 40),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green[50]
                  : (speakerA ? Colors.white : Colors.blueAccent),
              border: isActive
                  ? Border.all(color: Colors.green, width: 2)
                  : null,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomRight: speakerA
                    ? const Radius.circular(20)
                    : const Radius.circular(0),
                bottomLeft: !speakerA
                    ? const Radius.circular(20)
                    : const Radius.circular(0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text(
                //   speech,
                //   style: TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.w500,
                //     color: !speakerA && !isActive
                //         ? Colors.white
                //         : Colors.black87,
                //   ),
                //   softWrap: true,
                // ),

                // Text(
                //   furigana,
                //   style: TextStyle(
                //     fontSize: 14,
                //     color: isActive
                //         ? Colors.black54
                //         : (!speakerA ? Colors.white70 : Colors.grey[700]),
                //   ),
                //   softWrap: true,
                // ),
                FuriganaText(
                  text: furigana, // Passes the string containing bracket tags: "本当[ほんとう]？"
                  baseStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: !speakerA && !isActive
                        ? Colors.white
                        : Colors.black87,
                  ),
                  furiganaStyle: TextStyle(
                    fontSize: 10,
                    color: !speakerA && !isActive
                        ? Colors.white70
                        : Colors.blueGrey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "-----",
                    style: TextStyle(
                      color: !speakerA && !isActive
                          ? Colors.white70
                          : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ),
                Text(
                  myanmar,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive
                        ? Colors.black54
                        : (!speakerA ? Colors.white70 : Colors.grey[700]),
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ),
        if (!speakerA) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text(
              speaker,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAudioBottomBar(AudioPlayer player) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<PlayerState>(
              stream: player.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;

                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return Container(
                    margin: EdgeInsets.all(8.0),
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  );
                } else if (playing != true) {
                  return IconButton(
                    icon: const Icon(Icons.play_arrow),
                    iconSize: 40.0,
                    onPressed: player.play,
                  );
                } else if (processingState != ProcessingState.completed) {
                  return IconButton(
                    icon: const Icon(Icons.pause),
                    iconSize: 40.0,
                    onPressed: player.pause,
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.replay),
                    iconSize: 40.0,
                    onPressed: () => player.seek(Duration.zero),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
