class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreateNote extends CloudStorageException {}

class CouldNotGetAllNotes extends CloudStorageException {}

class CouldNotUpdateNote extends CloudStorageException {}

class CouldNotDeleteNote extends CloudStorageException {}
