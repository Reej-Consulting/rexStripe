/**
 * @description       : 
 * @author            : REEJ_AJ
 * @group             : 
 * @last modified on  : 10-12-2025
 * @last modified by  : REEJ_AJ
**/
public class PaymentIntentRequest {

    // Montant du paiement 
    public Decimal amount;

    // Code devise
    public String currencyIsoCode;

    // Id client Stripe (facultatif)
    public String customerId;

    // Libellé / description du paiement (facultatif)
    public String description;
}