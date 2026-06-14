<?php

$dir = __DIR__ . '/config/jwt';
if (!is_dir($dir)) {
    mkdir($dir, 0777, true);
}

$pass = getenv('JWT_PASSPHRASE') ?: 'dev_passphrase_change_me';
$config = ['private_key_bits' => 4096, 'private_key_type' => OPENSSL_KEYTYPE_RSA];
$res = openssl_pkey_new($config);
if ($res === false) {
    fwrite(STDERR, "OpenSSL key generation failed.\n");
    exit(1);
}

openssl_pkey_export($res, $priv, $pass);
$pub = openssl_pkey_get_details($res)['key'];
file_put_contents($dir . '/private.pem', $priv);
file_put_contents($dir . '/public.pem', $pub);

echo "JWT keys generated in config/jwt/\n";
