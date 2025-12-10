/**
 * @description       : 
 * @author            : REEJ_AJ
 * @group             : 
 * @last modified on  : 03-12-2025
 * @last modified by  : REEJ_AJ
**/
public with sharing class StripeConfigService {

    /**
     * Indique si l'org est un sandbox.
     */
    public static Boolean isSandbox() {
        return [
            SELECT IsSandbox
            FROM Organization
            LIMIT 1
        ].IsSandbox;
    }

    /**
     * Récupère l'enregistrement Stripe_Config__mdt
     * pour l'environnement courant (Sandbox / Production).
     */
    private static Stripe_Config__mdt getConfigRecord() {
        String env = isSandbox() ? 'Sandbox' : 'Production';

        return [
            SELECT ApiKey__c,
                   ApiPublicKey__c,
                   BaseURL__c,
                   Environment__c
            FROM Stripe_Config__mdt
            WHERE Environment__c = :env
            LIMIT 1
        ];
    }

    /**
     * Retourne les infos Stripe dans une Map :
     *  - apiKey    : clé secrète Stripe
     *  - publicKey : clé publique Stripe
     *  - baseUrl   : URL de base Stripe (ex: https://api.stripe.com/v1)
     */
    public static Map<String, String> getStripeKeys() {
        Stripe_Config__mdt cfg = getConfigRecord();

        if (cfg == null) {
            throw new AuraHandledException(
                'Aucune configuration Stripe trouvée pour l’environnement courant.'
            );
        }

        return new Map<String, String>{
            'apiKey'    => cfg.ApiKey__c,
            'publicKey' => cfg.ApiPublicKey__c,
            'baseUrl'   => cfg.BaseURL__c
        };
    }

    /**
     * Raccourci pour avoir juste la clé publique (utile côté LWC).
     */
    public static String getPublicKey() {
        return getStripeKeys().get('publicKey');
    }
}