class GazelleSSLCertificate {
  final String certificatePath;
  final String privateKeyPath;
  final String? privateKeyPassword;

  GazelleSSLCertificate({
    required this.certificatePath,
    required this.privateKeyPath,
    this.privateKeyPassword,
  });
}
