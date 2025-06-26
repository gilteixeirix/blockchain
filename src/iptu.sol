// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC20.sol"; //importando o contrato de token
contract IPTU  is ERC20  {
    address public prefeitura; // endereço da conta da prefeitura
    uint public anoImposto; // ano do IPTU
    
  

    struct Imovel {
        uint id;
        string idImovelnaPrefeitura;
        address proprietario;
        uint valorImposto;
        uint parcelas;
        uint  anoLancamento; // ano do IPTU
        address  prefeitura;
        uint valoparcelasPagas;
        bool pago; // se todas as parcelas foram pagas
    }

    mapping(uint => Imovel) public imoveis;
    uint public nextImovelId;

    // Evento para pagamento de parcela
    event ParcelaPago(uint imovelId, uint parcelaNumero, uint valorPago, address pagador);

    constructor(address _prefeitura, uint _anoImposto) {
        prefeitura = _prefeitura;
        anoImposto = _anoImposto;
        nextImovelId = 1;
    }

    // Cadastrar imóvel
    function lancarIptuImovel(
        string memory _idImovelnaPrefeitura,
        address _proprietario,
        uint _valorImposto,
        uint _totalParcelas
        
    ) public {
        imoveis[nextImovelId] = Imovel({
            id: nextImovelId,
            idImovelnaPrefeitura: _idImovelnaPrefeitura,
            proprietario: _proprietario,
            valorImposto: _valorImposto,
            parcelas: _totalParcelas,
            anoLancamento: anoImposto,
            prefeitura: prefeitura,
            valoparcelasPagas: 0,
            pago: false
        });
        nextImovelId++;
    }

    // Pagar parcela
    function pagarParcela(uint _imovelId) public payable {
        Imovel storage imovel = imoveis[_imovelId];

        require(msg.sender == imovel.proprietario, "Apenas o proprietario pode pagar");
        require(imovel.valoparcelasPagas < imovel.valorImposto, "Imovel ja totalmente pago");
        require(msg.value >= imovel.valorImposto / (imovel.parcelas), "Valor insuficiente para parcela");
        require(balanceOf[msg.sender] >= msg.value, "Saldo insuficiente do proprietario");
       
         // debita valor para a conta da proprietario
        balanceOf[msg.sender] -= msg.value;
        
       // Transferir valor para a conta da prefeitura
        balanceOf[prefeitura] += msg.value;

        // Registrar pagamento
         
        imovel.valoparcelasPagas += msg.value;
        if (imovel.valoparcelasPagas >= imovel.valorImposto) { // verificar se já pagou todas as parparcelas{
          imovel.pago = true;
       }
        emit ParcelaPago(_imovelId, imovel.valorImposto - imovel.valoparcelasPagas, msg.value, msg.sender);
    }

    // Obter detalhes do imóvel
    function getImovel(uint _imovelId) public view returns (
        string memory endereco,
        address proprietario,
        uint valorImposto,
        uint parcelas ,
        uint anoLancamento,
        address  prefeiturax,
        uint valoparcelasPagas
    ) {
        Imovel memory imovel = imoveis[_imovelId];
        return (
            imovel.idImovelnaPrefeitura,
            imovel.proprietario,
            imovel.valorImposto,
            imovel.parcelas,
            imovel.anoLancamento,
            imovel.prefeitura,
            imovel.valoparcelasPagas
        );
    }
 
}
