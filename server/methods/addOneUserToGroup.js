Meteor.methods({
	addOneUserToGroup: function(rid, user) {

		check (rid, String);

		if (RocketChat.authz.hasRole(this.userId, 'admin') === true) {
			var now, room;
			room = RocketChat.models.Rooms.findOneById(rid);
			if (room == null) {
				throw new Meteor.Error('error-invalid-room', 'Invalid room', {
					method: 'addOneUserToGroup'
				});
			}
			now = new Date();
			var subscription;
			subscription = RocketChat.models.Subscriptions.findOneByRoomIdAndUserId(rid, user._id);
			if (subscription != null) {
				return;
			}
			RocketChat.callbacks.run('beforeJoinRoom', user, room);
			RocketChat.models.Rooms.addUsernameById(rid, user.username);
			RocketChat.models.Subscriptions.createWithRoomAndUser(room, user, {
				ts: now,
				open: true,
				alert: true,
				unread: 1
			});
			RocketChat.models.Messages.createUserJoinWithRoomIdAndUser(rid, user, {
				ts: now
			});
			Meteor.defer(function() {});
			return RocketChat.callbacks.run('afterJoinRoom', user, room);
		} else {
			throw (new Meteor.Error(403, 'Access to Method Forbidden', {
				method: 'addOneUserToGroup'
			}));
		}
	}
});
