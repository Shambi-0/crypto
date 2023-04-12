/// <reference types="@rbxts/types"/>

interface KeyPair {
    Public: string,
    Secret: string
}

declare namespace Curve25519 {
    function GenerateKeyPair(): KeyPair;
    function GenerateSessionKey(Sender: string, Recipient: string): string;
}

declare namespace AES {
    function GenerateKey(): string;
    function Encrypt(Data: string, Key: string): string;
    function Decrypt(Data: string, Key: string): string;
}

export { Curve25519, AES };