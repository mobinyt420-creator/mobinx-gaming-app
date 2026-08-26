import { notificationsList } from '../data/mockData.js';

class NotificationService {
  constructor() {
    this.notifications = [...notificationsList];
  }

  getAll() {
    return this.notifications;
  }

  getByType(type) {
    if (!type || type === 'all') return this.notifications;
    return this.notifications.filter(n => n.type.toLowerCase() === type.toLowerCase());
  }

  getUnreadCount() {
    return this.notifications.filter(n => n.unread).length;
  }

  markAllAsRead() {
    this.notifications.forEach(n => { n.unread = false; });
    return this.notifications;
  }

  markAsRead(id) {
    const notif = this.notifications.find(n => n.id === id);
    if (notif) notif.unread = false;
    return notif;
  }
}

export const notificationService = new NotificationService();
