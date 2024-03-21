/// Represents an SSL certificate used for secure communication in Gazelle.
class GazelleSSLCertificate {
  /// The file path to the SSL certificate.
  final String certificatePath;

  /// The file path to the private key associated with the certificate.
  final String privateKeyPath;

  /// Optional password for accessing the private key.
  final String? privateKeyPassword;

  /// Constructs a GazelleSSLCertificate instance.
  ///
  /// [certificatePath] is the file path to the SSL certificate.
  ///
  /// [privateKeyPath] is the file path to the private key associated with the certificate.
  ///
  /// [privateKeyPassword] is an optional password for accessing the private key.
  const GazelleSSLCertificate({
    required this.certificatePath,
    required this.privateKeyPath,
    this.privateKeyPassword,
  });
}
