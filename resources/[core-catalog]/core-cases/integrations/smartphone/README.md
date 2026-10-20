# Integração com o smartphone

Copie `clientCases.lua` para o resource do smartphone e carregue-o junto dos demais clients:

```lua
client_scripts {
    "clientCases.lua",
    "client.lua"
}
```

O arquivo não sobrescreve nenhuma native, então a ordem de carregamento é livre.

A capinha é aplicada por dono: cada celular na cena recebe a capinha do jogador em que ele está anexado, lida do state bag replicado pelo servidor. O prop original do celular nunca é substituído — ele é escondido apenas no client e a capinha é anexada no osso da mão do ped, então funciona tanto com props criados no client quanto com props criados no servidor.

A capinha não pode ser anexada no próprio prop do celular: `SetEntityVisible` propaga para as entidades anexadas, então esconder o celular esconderia a capinha junto e nada apareceria na mão. O osso e os offsets usados são os mesmos do preview da loja (`Cases.Phone.Preview.Hand` e `Cases.Phone.PropAttach` em `config/config.lua`).

O modelo usado pelo smartphone precisa estar listado em `Cases.Phone.DefaultProps` (`config/config.lua`) para ser reconhecido.
