interface KeyPair {
    Public: string;
    Secret: string;
}

interface Curve25519 {
    GenerateKeyPair(): KeyPair;
    GenerateSessionKey(Sender: string, Recipient: string): string;
}

export default interface crypto {
    EC25519: Curve25519;
}