/**
 * @description       : 
 * @author            : REEJ_AJ
 * @group             : 
 * @last modified on  : 10-12-2025
 * @last modified by  : REEJ_AJ
**/
public with sharing class GenericStripeController {

    /**
     * Création d’un PaymentIntent Stripe.
     * Utilisable depuis LWC / Flow.
     *
     * @param amount      Montant en euros (> 0).
     * @param description Libellé du paiement (optionnel).
     * @param customerId  Id client Stripe (optionnel, peut être null).
     * @return            client_secret du PaymentIntent.
     */
    @AuraEnabled(cacheable=true)
    public static String createPaymentIntent(Decimal amount) {
        if (amount == null || amount <= 0) {
            throw new AuraHandledException('Le montant doit être strictement positif.');
        }

        PaymentIntentRequest req = new PaymentIntentRequest();
        req.amount          = amount;
        req.currencyIsoCode = 'EUR';

        return StripeWebService.createPaymentIntent(req);
    }

    /**
     * Clé publique Stripe pour l’environnement courant (Sandbox / Production).
     * Utilisée côté LWC pour initialiser Stripe.js.
     */
    @AuraEnabled(cacheable=true)
    public static String getStripePublicKey() {
        return StripeConfigService.getPublicKey();
    }

}