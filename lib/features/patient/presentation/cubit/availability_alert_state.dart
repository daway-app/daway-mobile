sealed class AvailabilityAlertState {
  const AvailabilityAlertState();
}

class AvailabilityAlertIdle extends AvailabilityAlertState {
  const AvailabilityAlertIdle();
}

class AvailabilityAlertSubscribing extends AvailabilityAlertState {
  const AvailabilityAlertSubscribing();
}

class AvailabilityAlertSubscribed extends AvailabilityAlertState {
  const AvailabilityAlertSubscribed();
}
