/// <reference types="@rbxts/types"/>
interface KeyPair {
    Public: string;
    Secret: string;
}

export default interface Curve25519 {
    GenerateKeyPair(): Readonly<KeyPair>;
    GenerateSessionKey(Sender: string, Recipient: string): string;
}