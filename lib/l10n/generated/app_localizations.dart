import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get commonSave;

  /// No description provided for @commonSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get commonSignOut;

  /// No description provided for @commonNotNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora não'**
  String get commonNotNow;

  /// No description provided for @commonDelete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get commonDelete;

  /// No description provided for @commonSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get commonSend;

  /// No description provided for @commonOk.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get commonClose;

  /// No description provided for @commonPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get commonPending;

  /// No description provided for @commonYes.
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get commonNo;

  /// No description provided for @commonError.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get commonError;

  /// No description provided for @commonSearch.
  ///
  /// In pt, this message translates to:
  /// **'Buscar...'**
  String get commonSearch;

  /// No description provided for @navItinerary.
  ///
  /// In pt, this message translates to:
  /// **'Itinerário'**
  String get navItinerary;

  /// No description provided for @navChat.
  ///
  /// In pt, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navCommunity.
  ///
  /// In pt, this message translates to:
  /// **'Comunidade'**
  String get navCommunity;

  /// No description provided for @navMyData.
  ///
  /// In pt, this message translates to:
  /// **'Meus dados'**
  String get navMyData;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In pt, this message translates to:
  /// **'CONTA'**
  String get settingsSectionAccount;

  /// No description provided for @settingsMyDocuments.
  ///
  /// In pt, this message translates to:
  /// **'Meus documentos'**
  String get settingsMyDocuments;

  /// No description provided for @settingsAccountData.
  ///
  /// In pt, this message translates to:
  /// **'Dados da conta'**
  String get settingsAccountData;

  /// No description provided for @settingsSectionPreferences.
  ///
  /// In pt, this message translates to:
  /// **'PREFERÊNCIAS'**
  String get settingsSectionPreferences;

  /// No description provided for @settingsMedicalConditions.
  ///
  /// In pt, this message translates to:
  /// **'Condições médicas'**
  String get settingsMedicalConditions;

  /// No description provided for @settingsNotifications.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get settingsNotifications;

  /// No description provided for @settingsDarkMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo escuro'**
  String get settingsDarkMode;

  /// No description provided for @settingsLightMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo claro'**
  String get settingsLightMode;

  /// No description provided for @settingsLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsSectionSupport.
  ///
  /// In pt, this message translates to:
  /// **'SUPORTE'**
  String get settingsSectionSupport;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de privacidade'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAboutUs.
  ///
  /// In pt, this message translates to:
  /// **'Sobre nós'**
  String get settingsAboutUs;

  /// No description provided for @settingsSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutDialogTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get settingsSignOutDialogTitle;

  /// No description provided for @settingsSignOutDialogContent.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja encerrar a sessão?'**
  String get settingsSignOutDialogContent;

  /// No description provided for @languagePickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar idioma'**
  String get languagePickerTitle;

  /// No description provided for @languageSystem.
  ///
  /// In pt, this message translates to:
  /// **'Padrão do sistema'**
  String get languageSystem;

  /// No description provided for @languagePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In pt, this message translates to:
  /// **'Inglês'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In pt, this message translates to:
  /// **'Espanhol'**
  String get languageSpanish;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo(a)!'**
  String get homeWelcomeTitle;

  /// No description provided for @homeWelcomeContent.
  ///
  /// In pt, this message translates to:
  /// **'Para aproveitar ao máximo a sua viagem, complete seu perfil com dados pessoais, restrições alimentares e contato de emergência.'**
  String get homeWelcomeContent;

  /// No description provided for @homeCompleteProfile.
  ///
  /// In pt, this message translates to:
  /// **'Completar perfil'**
  String get homeCompleteProfile;

  /// No description provided for @homeCameraError.
  ///
  /// In pt, this message translates to:
  /// **'Este dispositivo não suporta o uso da câmera.'**
  String get homeCameraError;

  /// No description provided for @homeNoFeedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum feed ativo'**
  String get homeNoFeedTitle;

  /// No description provided for @homeNoFeedDescription.
  ///
  /// In pt, this message translates to:
  /// **'Selecione uma missão na aba Início para visualizar e interagir com as publicações.'**
  String get homeNoFeedDescription;

  /// No description provided for @homeSelectMission.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Missão'**
  String get homeSelectMission;

  /// No description provided for @homeDeletePostTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir Publicação'**
  String get homeDeletePostTitle;

  /// No description provided for @homeDeletePostConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja excluir esta publicação?'**
  String get homeDeletePostConfirm;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo à missão!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In pt, this message translates to:
  /// **'Você foi adicionado a esta missão. Antes de confirmar sua participação, leia as informações a seguir com atenção. Este processo leva apenas alguns minutos.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingStart.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar'**
  String get onboardingStart;

  /// No description provided for @onboardingGoToApp.
  ///
  /// In pt, this message translates to:
  /// **'Ir para o app'**
  String get onboardingGoToApp;

  /// No description provided for @onboardingSkipForNow.
  ///
  /// In pt, this message translates to:
  /// **'Pular por agora'**
  String get onboardingSkipForNow;

  /// No description provided for @onboardingAllDone.
  ///
  /// In pt, this message translates to:
  /// **'Tudo certo!'**
  String get onboardingAllDone;

  /// No description provided for @onboardingParticipationConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Sua participação foi confirmada.\nPara garantir uma viagem tranquila, complete as etapas abaixo.'**
  String get onboardingParticipationConfirmed;

  /// No description provided for @onboardingQ1Title.
  ///
  /// In pt, this message translates to:
  /// **'Documentos de Viagem'**
  String get onboardingQ1Title;

  /// No description provided for @onboardingQ1Description.
  ///
  /// In pt, this message translates to:
  /// **'Confirme que você está ciente dos documentos necessários para esta missão.'**
  String get onboardingQ1Description;

  /// No description provided for @onboardingQ1OptionA.
  ///
  /// In pt, this message translates to:
  /// **'Confirmo que li e estou ciente de todos os documentos necessários (passaporte, vistos, vacinas, etc.) e sei que é de minha responsabilidade providenciá-los dentro do prazo.'**
  String get onboardingQ1OptionA;

  /// No description provided for @onboardingQ2Title.
  ///
  /// In pt, this message translates to:
  /// **'Viajantes Familiares'**
  String get onboardingQ2Title;

  /// No description provided for @onboardingQ2Description.
  ///
  /// In pt, this message translates to:
  /// **'Se houver outros membros do seu grupo familiar participando desta missão, informe os nomes abaixo.'**
  String get onboardingQ2Description;

  /// No description provided for @onboardingQ2Hint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Maria Silva, João Silva... (deixe em branco se não houver)'**
  String get onboardingQ2Hint;

  /// No description provided for @onboardingQ3Title.
  ///
  /// In pt, this message translates to:
  /// **'Particularidades'**
  String get onboardingQ3Title;

  /// No description provided for @onboardingQ3Description.
  ///
  /// In pt, this message translates to:
  /// **'Informe particularidades que a equipe organizadora deva saber para esta viagem.'**
  String get onboardingQ3Description;

  /// No description provided for @onboardingQ3Hint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: necessidades especiais, restrições alimentares, condições de saúde relevantes... (opcional)'**
  String get onboardingQ3Hint;

  /// No description provided for @onboardingQ4Title.
  ///
  /// In pt, this message translates to:
  /// **'Autorização de Uso de Imagem'**
  String get onboardingQ4Title;

  /// No description provided for @onboardingQ4Description.
  ///
  /// In pt, this message translates to:
  /// **'Você autoriza o uso da sua imagem em fotos e vídeos produzidos durante a missão para fins institucionais?'**
  String get onboardingQ4Description;

  /// No description provided for @onboardingQ4OptionA.
  ///
  /// In pt, this message translates to:
  /// **'Autorizo o uso da minha imagem para fins institucionais e de divulgação.'**
  String get onboardingQ4OptionA;

  /// No description provided for @onboardingQ4OptionB.
  ///
  /// In pt, this message translates to:
  /// **'Não autorizo o uso da minha imagem.'**
  String get onboardingQ4OptionB;

  /// No description provided for @onboardingQ5Title.
  ///
  /// In pt, this message translates to:
  /// **'Declaração de Participação'**
  String get onboardingQ5Title;

  /// No description provided for @onboardingQ5Description.
  ///
  /// In pt, this message translates to:
  /// **'Para concluir, confirme sua concordância com os termos desta missão.'**
  String get onboardingQ5Description;

  /// No description provided for @onboardingQ5OptionA.
  ///
  /// In pt, this message translates to:
  /// **'Concordo — declaro que li e estou de acordo com todas as informações e regras desta missão, comprometendo-me a seguir as orientações da equipe organizadora.'**
  String get onboardingQ5OptionA;

  /// No description provided for @onboardingQ5OptionB.
  ///
  /// In pt, this message translates to:
  /// **'Não concordo.'**
  String get onboardingQ5OptionB;

  /// No description provided for @onboardingQ5Warning.
  ///
  /// In pt, this message translates to:
  /// **'É necessário concordar para confirmar sua participação nesta missão.'**
  String get onboardingQ5Warning;

  /// No description provided for @onboardingQ5Error.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao enviar. Verifique sua conexão e tente novamente.'**
  String get onboardingQ5Error;

  /// No description provided for @onboardingGuidePersonalDataTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dados Pessoais'**
  String get onboardingGuidePersonalDataTitle;

  /// No description provided for @onboardingGuidePersonalDataSub.
  ///
  /// In pt, this message translates to:
  /// **'Complete seu perfil com nome, foto e informações de contato.'**
  String get onboardingGuidePersonalDataSub;

  /// No description provided for @onboardingGuideDocumentsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Documentos'**
  String get onboardingGuideDocumentsTitle;

  /// No description provided for @onboardingGuideDocumentsSub.
  ///
  /// In pt, this message translates to:
  /// **'Envie passaporte, visto e demais documentos exigidos para a viagem.'**
  String get onboardingGuideDocumentsSub;

  /// No description provided for @onboardingGuideMedicalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Condições Médicas'**
  String get onboardingGuideMedicalTitle;

  /// No description provided for @onboardingGuideMedicalSub.
  ///
  /// In pt, this message translates to:
  /// **'Informe alergias, medicamentos ou restrições de saúde importantes.'**
  String get onboardingGuideMedicalSub;

  /// No description provided for @profileChangePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Alterar foto de perfil'**
  String get profileChangePhoto;

  /// No description provided for @chatCurrentMission.
  ///
  /// In pt, this message translates to:
  /// **'MISSÃO ATUAL'**
  String get chatCurrentMission;

  /// No description provided for @chatGuides.
  ///
  /// In pt, this message translates to:
  /// **'GUIAS'**
  String get chatGuides;

  /// No description provided for @chatHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get chatHistory;

  /// No description provided for @chatHistorySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Todas as conversas'**
  String get chatHistorySubtitle;

  /// No description provided for @chatHistoryTileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de missões'**
  String get chatHistoryTileTitle;

  /// No description provided for @chatHistoryTileSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Ver conversas anteriores'**
  String get chatHistoryTileSubtitle;

  /// No description provided for @chatNoActiveMission.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma missão ativa'**
  String get chatNoActiveMission;

  /// No description provided for @chatPrevious.
  ///
  /// In pt, this message translates to:
  /// **'ANTERIORES'**
  String get chatPrevious;

  /// No description provided for @chatNoHistory.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum histórico encontrado'**
  String get chatNoHistory;

  /// No description provided for @chatYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get chatYesterday;

  /// No description provided for @notificationsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In pt, this message translates to:
  /// **'Lidas'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsClearAll.
  ///
  /// In pt, this message translates to:
  /// **'Limpar tudo'**
  String get notificationsClearAll;

  /// No description provided for @notificationsClearAllTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Limpar notificações'**
  String get notificationsClearAllTooltip;

  /// No description provided for @notificationsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Tudo em dia!'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Você não tem nenhuma notificação no momento.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get notificationsToday;

  /// No description provided for @notificationsYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get notificationsYesterday;

  /// No description provided for @notificationsThisWeek.
  ///
  /// In pt, this message translates to:
  /// **'Últimos 7 dias'**
  String get notificationsThisWeek;

  /// No description provided for @notificationsOlder.
  ///
  /// In pt, this message translates to:
  /// **'Mais antigas'**
  String get notificationsOlder;

  /// No description provided for @notificationsClearAllTitle.
  ///
  /// In pt, this message translates to:
  /// **'Limpar tudo'**
  String get notificationsClearAllTitle;

  /// No description provided for @notificationsClearAllConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Todas as notificações serão removidas permanentemente. Deseja continuar?'**
  String get notificationsClearAllConfirm;

  /// No description provided for @notificationsAccept.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar'**
  String get notificationsAccept;

  /// No description provided for @notificationsReject.
  ///
  /// In pt, this message translates to:
  /// **'Recusar'**
  String get notificationsReject;

  /// No description provided for @notificationsResolve.
  ///
  /// In pt, this message translates to:
  /// **'Resolver'**
  String get notificationsResolve;

  /// No description provided for @notificationsSeeMore.
  ///
  /// In pt, this message translates to:
  /// **'Ver mais'**
  String get notificationsSeeMore;

  /// No description provided for @notificationsSeeLess.
  ///
  /// In pt, this message translates to:
  /// **'Ver menos'**
  String get notificationsSeeLess;

  /// No description provided for @notificationsJustNow.
  ///
  /// In pt, this message translates to:
  /// **'agora'**
  String get notificationsJustNow;

  /// No description provided for @notificationsMinutesAgo.
  ///
  /// In pt, this message translates to:
  /// **'{minutes}min atrás'**
  String notificationsMinutesAgo(int minutes);

  /// No description provided for @notificationsHoursAgo.
  ///
  /// In pt, this message translates to:
  /// **'{hours}h atrás'**
  String notificationsHoursAgo(int hours);

  /// No description provided for @notificationsYesterdayTime.
  ///
  /// In pt, this message translates to:
  /// **'ontem'**
  String get notificationsYesterdayTime;

  /// No description provided for @notificationsDaysAgo.
  ///
  /// In pt, this message translates to:
  /// **'{days} dias atrás'**
  String notificationsDaysAgo(int days);

  /// No description provided for @notificationsWeeksAgo.
  ///
  /// In pt, this message translates to:
  /// **'{weeks} semana{plural} atrás'**
  String notificationsWeeksAgo(int weeks, String plural);

  /// No description provided for @documentsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meus documentos'**
  String get documentsTitle;

  /// No description provided for @documentsAddOrView.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar / Ver documentos'**
  String get documentsAddOrView;

  /// No description provided for @documentsPendingUpload.
  ///
  /// In pt, this message translates to:
  /// **'Pendente de envio'**
  String get documentsPendingUpload;

  /// No description provided for @documentsAwaitingApproval.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando aprovação'**
  String get documentsAwaitingApproval;

  /// No description provided for @documentsValid.
  ///
  /// In pt, this message translates to:
  /// **'Documento em dia'**
  String get documentsValid;

  /// No description provided for @documentsRejected.
  ///
  /// In pt, this message translates to:
  /// **'Recusado - Clique para reenviar'**
  String get documentsRejected;

  /// No description provided for @documentsExpired.
  ///
  /// In pt, this message translates to:
  /// **'Expirado - Clique para atualizar'**
  String get documentsExpired;

  /// No description provided for @accountDataTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dados da conta'**
  String get accountDataTitle;

  /// No description provided for @accountDataSaveReminder.
  ///
  /// In pt, this message translates to:
  /// **'Não esqueça de salvar suas alterações'**
  String get accountDataSaveReminder;

  /// No description provided for @accountDataFullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome Completo'**
  String get accountDataFullName;

  /// No description provided for @accountDataNickname.
  ///
  /// In pt, this message translates to:
  /// **'Nome para o crachá'**
  String get accountDataNickname;

  /// No description provided for @accountDataNicknameHelper.
  ///
  /// In pt, this message translates to:
  /// **'Esse nome será usado no seu crachá quando estiver em viagem.'**
  String get accountDataNicknameHelper;

  /// No description provided for @accountDataPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get accountDataPhone;

  /// No description provided for @accountDataEmergencySection.
  ///
  /// In pt, this message translates to:
  /// **'Contato de Emergência'**
  String get accountDataEmergencySection;

  /// No description provided for @accountDataEmergencyName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do Contato'**
  String get accountDataEmergencyName;

  /// No description provided for @accountDataRelationship.
  ///
  /// In pt, this message translates to:
  /// **'Grau de Parentesco (Ex: Pai, Mãe, etc)'**
  String get accountDataRelationship;

  /// No description provided for @accountDataEmergencyPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone de Emergência'**
  String get accountDataEmergencyPhone;

  /// No description provided for @accountDataCompany.
  ///
  /// In pt, this message translates to:
  /// **'Empresa'**
  String get accountDataCompany;

  /// No description provided for @accountDataCpf.
  ///
  /// In pt, this message translates to:
  /// **'CPF'**
  String get accountDataCpf;

  /// No description provided for @accountDataSsn.
  ///
  /// In pt, this message translates to:
  /// **'SSN'**
  String get accountDataSsn;

  /// No description provided for @accountDataBirthDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de Nascimento'**
  String get accountDataBirthDate;

  /// No description provided for @accountDataAddressSection.
  ///
  /// In pt, this message translates to:
  /// **'Endereço'**
  String get accountDataAddressSection;

  /// No description provided for @accountDataZipCode.
  ///
  /// In pt, this message translates to:
  /// **'CEP'**
  String get accountDataZipCode;

  /// No description provided for @accountDataCountry.
  ///
  /// In pt, this message translates to:
  /// **'País'**
  String get accountDataCountry;

  /// No description provided for @accountDataCountryPickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar País'**
  String get accountDataCountryPickerTitle;

  /// No description provided for @accountDataState.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get accountDataState;

  /// No description provided for @accountDataStatePickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar Estado'**
  String get accountDataStatePickerTitle;

  /// No description provided for @accountDataStateNonBrazil.
  ///
  /// In pt, this message translates to:
  /// **'Estado / Província'**
  String get accountDataStateNonBrazil;

  /// No description provided for @accountDataCity.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get accountDataCity;

  /// No description provided for @accountDataNeighborhood.
  ///
  /// In pt, this message translates to:
  /// **'Bairro'**
  String get accountDataNeighborhood;

  /// No description provided for @accountDataStreet.
  ///
  /// In pt, this message translates to:
  /// **'Rua'**
  String get accountDataStreet;

  /// No description provided for @accountDataNumber.
  ///
  /// In pt, this message translates to:
  /// **'Número'**
  String get accountDataNumber;

  /// No description provided for @accountDataComplement.
  ///
  /// In pt, this message translates to:
  /// **'Complemento'**
  String get accountDataComplement;

  /// No description provided for @accountDataSelectDate.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar data'**
  String get accountDataSelectDate;

  /// No description provided for @accountDataSaveButton.
  ///
  /// In pt, this message translates to:
  /// **'Salvar Alterações'**
  String get accountDataSaveButton;

  /// No description provided for @accountDataSuccessMessage.
  ///
  /// In pt, this message translates to:
  /// **'Dados atualizados com sucesso!'**
  String get accountDataSuccessMessage;

  /// No description provided for @accountDataRequiredFieldsError.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, preencha todos os campos obrigatórios.'**
  String get accountDataRequiredFieldsError;

  /// No description provided for @accountDataSelectPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar'**
  String get accountDataSelectPlaceholder;

  /// No description provided for @itineraryErrorPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Erro: '**
  String get itineraryErrorPrefix;

  /// No description provided for @itineraryCurrentMission.
  ///
  /// In pt, this message translates to:
  /// **'Missão Atual'**
  String get itineraryCurrentMission;

  /// No description provided for @itineraryFiltersActive.
  ///
  /// In pt, this message translates to:
  /// **'{count} filtros aplicados'**
  String itineraryFiltersActive(int count);

  /// No description provided for @itineraryFiltersNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem filtros aplicados'**
  String get itineraryFiltersNone;

  /// No description provided for @itineraryFilterButton.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar'**
  String get itineraryFilterButton;

  /// No description provided for @itineraryMissionEnded.
  ///
  /// In pt, this message translates to:
  /// **'Missão encerrada'**
  String get itineraryMissionEnded;

  /// No description provided for @itineraryEmptyFiltered.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum evento corresponde aos filtros.'**
  String get itineraryEmptyFiltered;

  /// No description provided for @itineraryStatusNow.
  ///
  /// In pt, this message translates to:
  /// **'Acontecendo agora'**
  String get itineraryStatusNow;

  /// No description provided for @itineraryStatusSoon.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get itineraryStatusSoon;

  /// No description provided for @itineraryFiltersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Filtros'**
  String get itineraryFiltersTitle;

  /// No description provided for @itineraryFilterEventType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de evento'**
  String get itineraryFilterEventType;

  /// No description provided for @itineraryFilterStartTime.
  ///
  /// In pt, this message translates to:
  /// **'Hora início'**
  String get itineraryFilterStartTime;

  /// No description provided for @itineraryFilterEndTime.
  ///
  /// In pt, this message translates to:
  /// **'Hora fim'**
  String get itineraryFilterEndTime;

  /// No description provided for @itineraryFilterSelectTime.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar'**
  String get itineraryFilterSelectTime;

  /// No description provided for @itineraryFilterClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get itineraryFilterClear;

  /// No description provided for @itineraryFilterApply.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get itineraryFilterApply;

  /// No description provided for @itineraryFilterEndBeforeStart.
  ///
  /// In pt, this message translates to:
  /// **'Hora fim deve ser posterior à hora início.'**
  String get itineraryFilterEndBeforeStart;

  /// No description provided for @itineraryFilterStartAfterEnd.
  ///
  /// In pt, this message translates to:
  /// **'Hora início deve ser anterior à hora fim.'**
  String get itineraryFilterStartAfterEnd;

  /// No description provided for @itineraryTypeFlight.
  ///
  /// In pt, this message translates to:
  /// **'Voo'**
  String get itineraryTypeFlight;

  /// No description provided for @itineraryTypeVisit.
  ///
  /// In pt, this message translates to:
  /// **'Visita'**
  String get itineraryTypeVisit;

  /// No description provided for @itineraryTypeHotel.
  ///
  /// In pt, this message translates to:
  /// **'Hotel'**
  String get itineraryTypeHotel;

  /// No description provided for @itineraryTypeFood.
  ///
  /// In pt, this message translates to:
  /// **'Alimentação'**
  String get itineraryTypeFood;

  /// No description provided for @itineraryTypeMeal.
  ///
  /// In pt, this message translates to:
  /// **'Refeição'**
  String get itineraryTypeMeal;

  /// No description provided for @itineraryTypeLeisure.
  ///
  /// In pt, this message translates to:
  /// **'Lazer'**
  String get itineraryTypeLeisure;

  /// No description provided for @itineraryTypeTransfer.
  ///
  /// In pt, this message translates to:
  /// **'Transfer'**
  String get itineraryTypeTransfer;

  /// No description provided for @itineraryTypeReturn.
  ///
  /// In pt, this message translates to:
  /// **'Retorno'**
  String get itineraryTypeReturn;

  /// No description provided for @itineraryTypeCheckin.
  ///
  /// In pt, this message translates to:
  /// **'Check-in'**
  String get itineraryTypeCheckin;

  /// No description provided for @itineraryTypeCheckout.
  ///
  /// In pt, this message translates to:
  /// **'Check-out'**
  String get itineraryTypeCheckout;

  /// No description provided for @itineraryTypeDisembark.
  ///
  /// In pt, this message translates to:
  /// **'Desembarque'**
  String get itineraryTypeDisembark;

  /// No description provided for @itineraryTypeConnection.
  ///
  /// In pt, this message translates to:
  /// **'Conexão'**
  String get itineraryTypeConnection;

  /// No description provided for @itineraryTypeAiRecommendation.
  ///
  /// In pt, this message translates to:
  /// **'Recomendação IA'**
  String get itineraryTypeAiRecommendation;

  /// No description provided for @itineraryTypeOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get itineraryTypeOther;

  /// No description provided for @itineraryMissionStartsIn.
  ///
  /// In pt, this message translates to:
  /// **'INICIA EM'**
  String get itineraryMissionStartsIn;

  /// No description provided for @itineraryMissionEndsToday.
  ///
  /// In pt, this message translates to:
  /// **'TERMINA\nHOJE'**
  String get itineraryMissionEndsToday;

  /// No description provided for @itineraryMissionEndsIn.
  ///
  /// In pt, this message translates to:
  /// **'TERMINA EM'**
  String get itineraryMissionEndsIn;

  /// No description provided for @itineraryMissionDays.
  ///
  /// In pt, this message translates to:
  /// **'dias'**
  String get itineraryMissionDays;

  /// No description provided for @itineraryTravelData.
  ///
  /// In pt, this message translates to:
  /// **'Dados da viagem'**
  String get itineraryTravelData;

  /// No description provided for @itineraryEmergencyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Canais de Emergência'**
  String get itineraryEmergencyTitle;

  /// No description provided for @itineraryEmergencyLocation.
  ///
  /// In pt, this message translates to:
  /// **'Localização atual: {country}'**
  String itineraryEmergencyLocation(String country);

  /// No description provided for @itineraryEmergencyPolice.
  ///
  /// In pt, this message translates to:
  /// **'Polícia'**
  String get itineraryEmergencyPolice;

  /// No description provided for @itineraryEmergencyFire.
  ///
  /// In pt, this message translates to:
  /// **'Bombeiros'**
  String get itineraryEmergencyFire;

  /// No description provided for @itineraryEmergencyMedical.
  ///
  /// In pt, this message translates to:
  /// **'Emergência Médica'**
  String get itineraryEmergencyMedical;

  /// No description provided for @itineraryEmergencyLocationDenied.
  ///
  /// In pt, this message translates to:
  /// **'Permissão de localização negada'**
  String get itineraryEmergencyLocationDenied;

  /// No description provided for @itineraryEmergencyLocationDeniedForever.
  ///
  /// In pt, this message translates to:
  /// **'Permissão de localização permanentemente negada'**
  String get itineraryEmergencyLocationDeniedForever;

  /// No description provided for @itineraryEmergencyLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar contatos: {error}'**
  String itineraryEmergencyLoadError(String error);

  /// No description provided for @itineraryViewOnMap.
  ///
  /// In pt, this message translates to:
  /// **'Ver no Mapa'**
  String get itineraryViewOnMap;

  /// No description provided for @itineraryWebsite.
  ///
  /// In pt, this message translates to:
  /// **'Site'**
  String get itineraryWebsite;

  /// No description provided for @itineraryBookingQuoting.
  ///
  /// In pt, this message translates to:
  /// **'Cotando'**
  String get itineraryBookingQuoting;

  /// No description provided for @itineraryBookingQuoted.
  ///
  /// In pt, this message translates to:
  /// **'Cotado'**
  String get itineraryBookingQuoted;

  /// No description provided for @itineraryFlight.
  ///
  /// In pt, this message translates to:
  /// **'Voo'**
  String get itineraryFlight;

  /// No description provided for @itineraryDelayed.
  ///
  /// In pt, this message translates to:
  /// **'ATRASADO'**
  String get itineraryDelayed;

  /// No description provided for @itineraryDelayedWithTime.
  ///
  /// In pt, this message translates to:
  /// **'ATRASADO {delay}'**
  String itineraryDelayedWithTime(String delay);

  /// No description provided for @itineraryFromCity.
  ///
  /// In pt, this message translates to:
  /// **'de {city}'**
  String itineraryFromCity(String city);

  /// No description provided for @itineraryToCity.
  ///
  /// In pt, this message translates to:
  /// **'para {city}'**
  String itineraryToCity(String city);

  /// No description provided for @itineraryConnectionsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escalas ({count})'**
  String itineraryConnectionsTitle(int count);

  /// No description provided for @itineraryConnectionsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} escala{plural}'**
  String itineraryConnectionsCount(int count, String plural);

  /// No description provided for @itineraryDirectFlight.
  ///
  /// In pt, this message translates to:
  /// **'Voo direto'**
  String get itineraryDirectFlight;

  /// No description provided for @itineraryConnectionTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo de conexão: {time}'**
  String itineraryConnectionTime(String time);

  /// No description provided for @itineraryNextDay.
  ///
  /// In pt, this message translates to:
  /// **'Dia seguinte'**
  String get itineraryNextDay;

  /// No description provided for @itineraryTravelTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo de deslocamento: {duration}'**
  String itineraryTravelTime(String duration);

  /// No description provided for @itineraryChecklistTitle.
  ///
  /// In pt, this message translates to:
  /// **'Checklist da missão'**
  String get itineraryChecklistTitle;

  /// No description provided for @itineraryDocumentsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Documentos da missão'**
  String get itineraryDocumentsTitle;

  /// No description provided for @itineraryMission.
  ///
  /// In pt, this message translates to:
  /// **'Missão'**
  String get itineraryMission;

  /// No description provided for @itineraryGroup.
  ///
  /// In pt, this message translates to:
  /// **'Grupo'**
  String get itineraryGroup;

  /// No description provided for @itineraryStarts.
  ///
  /// In pt, this message translates to:
  /// **'Começa'**
  String get itineraryStarts;

  /// No description provided for @itineraryEnds.
  ///
  /// In pt, this message translates to:
  /// **'Termina'**
  String get itineraryEnds;

  /// No description provided for @itineraryInDays.
  ///
  /// In pt, this message translates to:
  /// **'em {count} dias'**
  String itineraryInDays(int count);

  /// No description provided for @itineraryTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'amanhã'**
  String get itineraryTomorrow;

  /// No description provided for @itineraryToday.
  ///
  /// In pt, this message translates to:
  /// **'hoje'**
  String get itineraryToday;

  /// No description provided for @itineraryStarted.
  ///
  /// In pt, this message translates to:
  /// **'iniciada'**
  String get itineraryStarted;

  /// No description provided for @itineraryEnded.
  ///
  /// In pt, this message translates to:
  /// **'encerrada'**
  String get itineraryEnded;

  /// No description provided for @itineraryNoMaterials.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum material disponível'**
  String get itineraryNoMaterials;

  /// No description provided for @itineraryOpenMaterialError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o material'**
  String get itineraryOpenMaterialError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
