import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_flutter/components/admin_message_item.dart';
import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbird_flutter/components/channel_title_text_view.dart';
import 'package:sendbird_flutter/components/file_message_item.dart';
import 'package:sendbird_flutter/components/message_input.dart';
import 'package:sendbird_flutter/components/user_message_item.dart';
import 'package:sendbird_flutter/view_models/channel_view_model.dart';

import 'package:sendbirdsdk/sendbirdsdk.dart';

class ChannelScreen extends StatefulWidget {
  final GroupChannel channel;

  ChannelScreen({this.channel, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  ChannelViewModel model;

  @override
  void initState() {
    model = ChannelViewModel(channel: widget.channel);
    model.loadMessages(reload: true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildNavigationBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildContent(),
            MessageInput(
              onPressPlus: () {
                model.showPicker();
              },
              onPressSend: (text) {
                model.onSendUserMessage(text);
              },
            )
          ],
        ),
      ),
    );
  }

  // build helpers

  Widget _buildNavigationBar() {
    final currentUser = model.currentUser;

    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 65,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              BackButton(color: Theme.of(context).primaryColor),
              SizedBox(width: 2),
              AvatarView(
                channel: widget.channel,
                currentUserId: currentUser.userId,
                width: 25,
                height: 25,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //bind channel and current user data into title view
                    ChannelTitleTextView(widget.channel, currentUser.userId)
                  ],
                ),
              ),
              // Icon(Icons.settings, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ChangeNotifierProvider<ChannelViewModel>(
      builder: (context) => model,
      child: Consumer<ChannelViewModel>(builder: (context, value, child) {
        return Expanded(
          child: ListView.builder(
            controller: model.lstController,
            itemCount: model.itemCount,
            shrinkWrap: true,
            reverse: true,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            itemBuilder: (context, index) {
              if (index == model.messages.length && model.hasNext) {
                return Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final message = model.messages[index];
              final prev = (index < model.messages.length - 1)
                  ? model.messages[index + 1]
                  : null;
              final next = index == 0 ? null : model.messages[index - 1];
              final isMyMessage =
                  message.sender?.userId == model.currentUser.userId;

              if (message is FileMessage) {
                return FileMessageItem(
                  curr: message,
                  prev: prev,
                  next: next,
                  isMyMessage: isMyMessage,
                );
              } else if (message is AdminMessage) {
                return AdminMessageItem(curr: message);
              } else {
                return UserMessageItem(
                  curr: message,
                  prev: prev,
                  next: next,
                  isMyMessage: isMyMessage,
                );
              }
            },
          ),
        );
      }),
    );
  }
}
