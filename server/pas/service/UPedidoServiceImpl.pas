unit UPedidoServiceImpl;

interface

uses
  UPedidoServiceIntf, UPizzaTamanhoEnum, UPizzaSaborEnum,
  UPedidoRepositoryIntf, UPedidoRetornoDTOImpl, UClienteServiceIntf,
  FireDAC.Comp.Client;

type
  TPedidoService = class(TInterfacedObject, IPedidoService)
  private
    FPedidoRepository: IPedidoRepository;
    FClienteService: IClienteService;

    function calcularValorPedido(const APizzaTamanho: TPizzaTamanhoEnum): Currency;
    function calcularTempoPreparo(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum): Integer;
  public
    function efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const ADocumentoCliente: String): TPedidoRetornoDTO;
    function ConsultarPedido(const ADocumento: String): String;
    function ConsultarPed(const ADocumentoCliente: string): TPedidoRetornoDTO;


    constructor Create; reintroduce;

  end;

implementation

uses
  UPedidoRepositoryImpl, System.SysUtils, UClienteServiceImpl;

{ TPedidoService }

function TPedidoService.calcularTempoPreparo(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum): Integer;
begin
  Result := 15;
  case APizzaTamanho of
    enPequena:
      Result := 15;
    enMedia:
      Result := 20;
    enGrande:
      Result := 25;
  end;

  if (APizzaSabor = enPortuguesa) then
    Result := Result + 5;
end;

function TPedidoService.calcularValorPedido(const APizzaTamanho: TPizzaTamanhoEnum): Currency;
begin
  Result := 20;
  case APizzaTamanho of
    enPequena:
      Result := 20;
    enMedia:
      Result := 30;
    enGrande:
      Result := 40;
  end;
end;

function TPedidoService.ConsultarPed(const ADocumentoCliente: string): TPedidoRetornoDTO;
var
  oQuery:TFdQuery;
begin
try
  oQuery := TFDQuery.Create(nil);
  FPedidoRepository.ConsultaPed(ADocumentoCliente,oQuery);

  if oQuery.IsEmpty then
    raise Exception.Create('N�o h� pedidos localizados para o documento: ' + ADocumentoCliente + ' !');

  Result := TPedidoRetornoDTO.Create(
            oQuery.FieldByName('tamanho').Value,
            oQuery.FieldByName('sabor').Value,
            oQuery.FieldByName('vl_pedido').Value,
            oQuery.FieldByName('nr_tempopedido').Value
              );

finally
  oQuery.Free;

end;


end;

function TPedidoService.ConsultarPedido(
  const ADocumento: String): String;
begin
  Result := FPedidoRepository.ConsultarPedido(ADocumento);
end;

constructor TPedidoService.Create;
begin
  inherited;

  FPedidoRepository := TPedidoRepository.Create;
  FClienteService := TClienteService.Create;
end;

function TPedidoService.efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const ADocumentoCliente: String)
  : TPedidoRetornoDTO;
var
  oValorPedido: Currency;
  oTempoPreparo: Integer;
  oCodigoCliente: Integer;
begin
  oValorPedido := calcularValorPedido(APizzaTamanho);
  oTempoPreparo := calcularTempoPreparo(APizzaTamanho, APizzaSabor);
  oCodigoCliente := FClienteService.adquirirCodigoCliente(ADocumentoCliente);

  FPedidoRepository.efetuarPedido(APizzaTamanho, APizzaSabor, oValorPedido, oTempoPreparo, oCodigoCliente);
  Result := TPedidoRetornoDTO.Create(APizzaTamanho, APizzaSabor, oValorPedido, oTempoPreparo);
end;

end.
