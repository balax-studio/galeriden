// =============================================================================
// Galeriden - Infinitown 3D Low-Poly City World Engine (Three.js)
// Interactive Buildings, Dynamic Lock Badges, Notification Alerts & Live Bridge
// =============================================================================

(function () {
  'use strict';

  // --- 1. Scene, Camera, Renderer Setup ---
  const container = document.getElementById('canvas-container');
  const canvas = document.getElementById('canvas3d');
  const tooltip = document.getElementById('building-tooltip');
  const tagsContainer = document.getElementById('building-tags-container');

  const scene = new THREE.Scene();
  
  // Vibrant, cheerful daylight atmosphere (Infinitown style)
  const skyColorDay = new THREE.Color(0xa5f3fc);
  const fogColorDay = new THREE.Color(0xbae6fd);
  scene.background = skyColorDay;
  scene.fog = new THREE.FogExp2(fogColorDay, 0.0035);

  const width = container.clientWidth || window.innerWidth;
  const height = container.clientHeight || window.innerHeight;

  // Perspective camera tuned for isometric tilt-shift miniature diorama look
  const camera = new THREE.PerspectiveCamera(30, width / height, 1, 600);
  camera.position.set(72, 68, 72);

  const renderer = new THREE.WebGLRenderer({
    canvas: canvas,
    antialias: true,
    powerPreference: 'high-performance',
    alpha: false,
  });
  renderer.setSize(width, height);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  renderer.outputEncoding = THREE.sRGBEncoding;

  // OrbitControls with tuned bounds for smooth free panning & exploration
  const controls = new THREE.OrbitControls(camera, canvas);
  controls.enableDamping = true;
  controls.dampingFactor = 0.08;
  controls.target.set(0, 0, 0);
  controls.minDistance = 20;
  controls.maxDistance = 170;
  controls.minPolarAngle = Math.PI / 7; // ~25 deg
  controls.maxPolarAngle = Math.PI / 2.25; // ~80 deg
  controls.enablePan = true;
  controls.screenSpacePanning = false; // Pan smoothly along ground plane (X/Z)
  controls.panSpeed = 1.1;
  controls.rotateSpeed = 0.7;
  controls.zoomSpeed = 0.9;

  // Left click / 1-finger drags & pans the city smoothly; Right click rotates angle
  controls.mouseButtons = {
    LEFT: THREE.MOUSE.PAN,
    MIDDLE: THREE.MOUSE.DOLLY,
    RIGHT: THREE.MOUSE.ROTATE,
  };
  controls.touches = {
    ONE: THREE.TOUCH.PAN,
    TWO: THREE.TOUCH.DOLLY_ROTATE,
  };

  // --- 2. Lighting System ---
  const ambientLight = new THREE.AmbientLight(0xfffbeb, 0.65);
  scene.add(ambientLight);

  const hemiLight = new THREE.HemisphereLight(0xbae6fd, 0x3d7a46, 0.55);
  scene.add(hemiLight);

  const sunLight = new THREE.DirectionalLight(0xfff7ed, 1.4);
  sunLight.position.set(65, 95, 45);
  sunLight.castShadow = true;
  sunLight.shadow.mapSize.width = 2048;
  sunLight.shadow.mapSize.height = 2048;
  sunLight.shadow.camera.near = 10;
  sunLight.shadow.camera.far = 300;
  const shadowRange = 75;
  sunLight.shadow.camera.left = -shadowRange;
  sunLight.shadow.camera.right = shadowRange;
  sunLight.shadow.camera.top = shadowRange;
  sunLight.shadow.camera.bottom = -shadowRange;
  sunLight.shadow.bias = -0.0004;
  scene.add(sunLight);

  const streetLights = [];
  const neonMaterials = [];
  const animatedSmokes = [];
  const animatedCars = [];
  const animatedClouds = [];
  const interactableObjects = [];
  const buildingInstances = [];

  // Current Player Game State (synced from Flutter)
  let gameState = {
    level: 1,
    balance: 50000,
    unlockedBuildings: ['/showroom', '/marketplace', '/workshop'],
    badges: {},
  };

  // --- 3. Palettes & Materials ---
  const matCityGround = new THREE.MeshLambertMaterial({ color: 0x4ade80, flatShading: true });
  const matOuterGround = new THREE.MeshLambertMaterial({ color: 0x22c55e, flatShading: true });
  const matMountain = new THREE.MeshLambertMaterial({ color: 0x166534, flatShading: true });
  const matMountainSnow = new THREE.MeshLambertMaterial({ color: 0xe0f2fe, flatShading: true });
  const matRiver = new THREE.MeshLambertMaterial({ color: 0x38bdf8, flatShading: true, transparent: true, opacity: 0.88 });
  const matRoad = new THREE.MeshLambertMaterial({ color: 0x272e39, flatShading: true });
  const matRoadLine = new THREE.MeshBasicMaterial({ color: 0xfbbf24 });
  const matSidewalk = new THREE.MeshLambertMaterial({ color: 0x94a3b8, flatShading: true });
  const matPlaza = new THREE.MeshLambertMaterial({ color: 0x334155, flatShading: true });
  const matCloud = new THREE.MeshLambertMaterial({ color: 0xffffff, flatShading: true, transparent: true, opacity: 0.92 });

  const worldGroup = new THREE.Group();
  scene.add(worldGroup);

  // --- 4. Surrounding Landscape ---
  const valleyGeo = new THREE.PlaneGeometry(420, 420, 20, 20);
  const valleyMesh = new THREE.Mesh(valleyGeo, matOuterGround);
  valleyMesh.rotation.x = -Math.PI / 2;
  valleyMesh.position.y = -0.05;
  valleyMesh.receiveShadow = true;
  worldGroup.add(valleyMesh);

  const cityBaseGeo = new THREE.PlaneGeometry(100, 100);
  const cityBase = new THREE.Mesh(cityBaseGeo, matCityGround);
  cityBase.rotation.x = -Math.PI / 2;
  cityBase.position.y = 0.01;
  cityBase.receiveShadow = true;
  worldGroup.add(cityBase);

  const riverGeo = new THREE.PlaneGeometry(18, 400);
  const riverMesh = new THREE.Mesh(riverGeo, matRiver);
  riverMesh.rotation.x = -Math.PI / 2;
  riverMesh.rotation.z = Math.PI / 4.2;
  riverMesh.position.set(65, 0.02, 0);
  riverMesh.receiveShadow = true;
  worldGroup.add(riverMesh);

  function createMountain(x, z, radius, height, hasSnow = false) {
    const geo = new THREE.ConeGeometry(radius, height, 6);
    const m = new THREE.Mesh(geo, matMountain);
    m.position.set(x, height / 2 - 0.2, z);
    m.rotation.y = Math.random() * Math.PI;
    m.castShadow = true;
    m.receiveShadow = true;
    worldGroup.add(m);

    if (hasSnow) {
      const snowGeo = new THREE.ConeGeometry(radius * 0.45, height * 0.35, 6);
      const snow = new THREE.Mesh(snowGeo, matMountainSnow);
      snow.position.set(x, height * 0.82, z);
      snow.rotation.y = m.rotation.y;
      worldGroup.add(snow);
    }
  }

  const MOUNTAINS = [
    [-110, -90, 28, 38, true], [-80, -115, 24, 32, true], [-130, -40, 26, 35, false],
    [-125, 45, 28, 36, true], [-110, 95, 25, 30, false], [-60, 125, 30, 42, true],
    [50, -125, 26, 34, true], [105, -100, 32, 44, true], [130, -45, 28, 36, false],
    [125, 60, 30, 40, true], [95, 110, 26, 35, true], [40, 130, 28, 36, false],
  ];
  MOUNTAINS.forEach(([x, z, r, h, snow]) => createMountain(x, z, r, h, snow));

  function createCloud(x, y, z, scale) {
    const cg = new THREE.Group();
    cg.position.set(x, y, z);
    cg.scale.set(scale, scale, scale);

    const base = new THREE.Mesh(new THREE.DodecahedronGeometry(3.5), matCloud);
    cg.add(base);

    const puff1 = new THREE.Mesh(new THREE.DodecahedronGeometry(2.6), matCloud);
    puff1.position.set(-2.4, 0.4, 0);
    cg.add(puff1);

    const puff2 = new THREE.Mesh(new THREE.DodecahedronGeometry(2.8), matCloud);
    puff2.position.set(2.4, -0.2, 0.5);
    cg.add(puff2);

    const puff3 = new THREE.Mesh(new THREE.DodecahedronGeometry(2.2), matCloud);
    puff3.position.set(0.6, 1.4, -0.4);
    cg.add(puff3);

    worldGroup.add(cg);
    animatedClouds.push({ group: cg, speed: 0.8 + Math.random() * 0.6 });
  }

  createCloud(-60, 34, -40, 1.2);
  createCloud(20, 38, -60, 1.0);
  createCloud(-30, 32, 50, 1.4);
  createCloud(70, 36, 40, 1.1);

  // --- 5. Clean Road Grid System ---
  function createRoad(x, z, w, d) {
    const roadGeo = new THREE.PlaneGeometry(w, d);
    const roadMesh = new THREE.Mesh(roadGeo, matRoad);
    roadMesh.rotation.x = -Math.PI / 2;
    roadMesh.position.set(x, 0.03, z);
    roadMesh.receiveShadow = true;
    worldGroup.add(roadMesh);

    const lineGeo = new THREE.PlaneGeometry(w > d ? w : 0.3, w > d ? 0.3 : d);
    const lineMesh = new THREE.Mesh(lineGeo, matRoadLine);
    lineMesh.rotation.x = -Math.PI / 2;
    lineMesh.position.set(x, 0.04, z);
    worldGroup.add(lineMesh);

    const isHorizontal = w > d;
    const swGeo = new THREE.PlaneGeometry(isHorizontal ? w : 1.2, isHorizontal ? 1.2 : d);
    
    const sw1 = new THREE.Mesh(swGeo, matSidewalk);
    sw1.rotation.x = -Math.PI / 2;
    sw1.position.set(isHorizontal ? x : x - w / 2 - 0.6, 0.05, isHorizontal ? z - d / 2 - 0.6 : z);
    sw1.receiveShadow = true;
    worldGroup.add(sw1);

    const sw2 = new THREE.Mesh(swGeo, matSidewalk);
    sw2.rotation.x = -Math.PI / 2;
    sw2.position.set(isHorizontal ? x : x + w / 2 + 0.6, 0.05, isHorizontal ? z + d / 2 + 0.6 : z);
    sw2.receiveShadow = true;
    worldGroup.add(sw2);
  }

  // Inner Ring Avenues
  createRoad(0, -18, 78, 6);
  createRoad(0, 18, 78, 6);
  createRoad(-18, 0, 6, 78);
  createRoad(18, 0, 6, 78);

  // Outer Connecting Avenues
  createRoad(0, -36, 78, 6);
  createRoad(0, 36, 78, 6);
  createRoad(-36, 0, 6, 78);
  createRoad(36, 0, 6, 78);

  // Center Plaza
  const plazaGeo = new THREE.BoxGeometry(24, 0.1, 24);
  const plazaMesh = new THREE.Mesh(plazaGeo, matPlaza);
  plazaMesh.position.set(0, 0.05, 0);
  plazaMesh.receiveShadow = true;
  worldGroup.add(plazaMesh);

  // Parking Bays on Plaza
  const bayMat = new THREE.MeshBasicMaterial({ color: 0x38bdf8, transparent: true, opacity: 0.4 });
  for (let r = 0; r < 2; r++) {
    for (let c = 0; c < 3; c++) {
      const bay = new THREE.Mesh(new THREE.PlaneGeometry(3.0, 4.6), bayMat);
      bay.rotation.x = -Math.PI / 2;
      bay.position.set(-5.5 + c * 3.8, 0.12, 2.5 + r * 5.0);
      worldGroup.add(bay);
    }
  }

  // --- 6. Building Definitions & Level/Cost Requirements ---
  const BUILDING_DEFS = [
    // Center
    {
      id: 'showroom',
      route: '/showroom',
      name: 'Miras Oto Galeri Showroom',
      shortName: 'Showroom',
      subtitle: 'Vitrin & Satış Galerisi',
      emoji: '🏛️',
      color: 0x0284c7,
      pos: [0, 0, -4.5],
      tagHeight: 10.5,
      requiredLevel: 1,
      unlockCost: 0,
      description: 'Dede mirası ana galeri binan. Araçlarını vitrine koy ve müşterilere sat.',
      builder: createCentralShowroomGroup,
    },
    // 1. Sanayi & Atölye
    {
      id: 'workshop',
      route: '/workshop',
      name: 'Tamir Atölyesi',
      shortName: 'Tamirhane',
      subtitle: 'Motor & Kaporta Onarımı',
      emoji: '🔧',
      color: 0xf59e0b,
      pos: [-27, 0, -27],
      tagHeight: 8.5,
      requiredLevel: 1,
      unlockCost: 0,
      description: 'Hasarlı araçları tamir et, motor ve kaportasını yenileyip değerini artır.',
      builder: createWorkshopBuilding,
    },
    {
      id: 'car-wash',
      route: '/car-wash',
      name: 'Oto Yıkama & Detailing',
      shortName: 'Oto Yıkama',
      subtitle: 'Pasta Cila & Detaylı Temizlik',
      emoji: '🚿',
      color: 0x06b6d4,
      pos: [-27, 0, -7],
      tagHeight: 6.8,
      requiredLevel: 2,
      unlockCost: 15000,
      description: 'Araçları yıka ve pasta-cila ile parlat, müşterilerin tekliflerini yükselt.',
      builder: createCarWashBuilding,
    },
    {
      id: 'tuning-studio',
      route: '/tuning-studio',
      name: 'VIP Tuning Garajı',
      shortName: 'VIP Tuning',
      subtitle: 'Performans & Modifiye',
      emoji: '⚡',
      color: 0xeab308,
      pos: [-6, 0, -27],
      tagHeight: 7.2,
      requiredLevel: 5,
      unlockCost: 120000,
      description: 'Özel spor egzoz, çelik jant ve yazılım paketleriyle araçları roket gibi yap.',
      builder: createTuningBuilding,
    },

    // 2. Pazar, Hurda & Fırsat
    {
      id: 'marketplace',
      route: '/marketplace',
      name: 'İkinci El Açık Oto Pazarı',
      shortName: 'Oto Pazar',
      subtitle: 'Araç Alım & Pazarlık',
      emoji: '🚗',
      color: 0x3b82f6,
      pos: [-27, 0, 7],
      tagHeight: 5.8,
      requiredLevel: 1,
      unlockCost: 0,
      description: 'Satıcılarla pazarlık et, kelepir araçları kap ve galerine ekle.',
      builder: createMarketplaceBuilding,
    },
    {
      id: 'auction',
      route: '/auction',
      name: 'Canlı İhale Salonu',
      shortName: 'Canlı İhale',
      subtitle: 'Açık Artırma & Fırsat',
      emoji: '🔨',
      color: 0xef4444,
      pos: [-6, 0, 27],
      tagHeight: 7.5,
      requiredLevel: 4,
      unlockCost: 60000,
      description: 'Canlı açık artırmada diğer galericilerle kapış, nadir araçları kazan.',
      builder: createAuctionBuilding,
    },
    {
      id: 'scrapyard',
      route: '/scrapyard',
      name: 'Hurdalık & Parça Deposu',
      shortName: 'Hurdalık',
      subtitle: 'Pert Araç & Yedek Parça',
      emoji: '🛞',
      color: 0xf97316,
      pos: [-27, 0, 27],
      tagHeight: 7.0,
      requiredLevel: 3,
      unlockCost: 40000,
      description: 'Hurdaya ayrılmış pert araçları ucuza al, parçalarını söküp paraya çevir.',
      builder: createScrapyardBuilding,
    },
    {
      id: 'black-market',
      route: '/black-market',
      name: 'Yeraltı Karaborsa Deposu',
      shortName: 'Karaborsa',
      subtitle: 'Riskli & Gizli İlanlar',
      emoji: '🕶️',
      color: 0x475569,
      pos: [-42, 0, 0],
      tagHeight: 6.2,
      requiredLevel: 8,
      unlockCost: 350000,
      description: 'Kayıt dışı gizli araçlar, dev kâr marjları. Polis baskınına dikkat!',
      builder: createBlackMarketBuilding,
    },

    // 3. Finans & Borsa
    {
      id: 'finance',
      route: '/finance',
      name: 'Banka & Finans Merkezi',
      shortName: 'Banka',
      subtitle: 'Kredi · Çek · Senet',
      emoji: '🏛️',
      color: 0x10b981,
      pos: [27, 0, -27],
      tagHeight: 8.5,
      requiredLevel: 3,
      unlockCost: 35000,
      description: 'Galerini büyütmek için düşük faizli ticari kredi kullan veya çek kırdır.',
      builder: createBankBuilding,
    },
    {
      id: 'stock-market',
      route: '/stock-market',
      name: 'Otomotiv Borsası',
      shortName: 'Borsa',
      subtitle: 'Hisse Senedi & Yatırım',
      emoji: '📈',
      color: 0x22c55e,
      pos: [6, 0, -27],
      tagHeight: 16.5,
      requiredLevel: 7,
      unlockCost: 250000,
      description: 'Dev otomotiv ve enerji hisselerine yatırım yap, temettü geliri topla.',
      builder: createStockMarketBuilding,
    },
    {
      id: 'bank-investments',
      route: '/bank-investments',
      name: 'Mevduat & Yatırım Kasası',
      shortName: 'Kasa Fonu',
      subtitle: 'Vadeli Faiz & Altın Fonu',
      emoji: '💰',
      color: 0xd97706,
      pos: [27, 0, -7],
      tagHeight: 7.2,
      requiredLevel: 6,
      unlockCost: 180000,
      description: 'Boştaki nakit paranı vadeli faize veya güvenli altına yatırıp günlük kâr al.',
      builder: createInvestmentVaultBuilding,
    },

    // 4. Kurumsal & Büyüme
    {
      id: 'rent-a-car',
      route: '/rent-a-car',
      name: 'Rent a Car Filo Merkezi',
      subtitle: 'Günlük & Aylık Kiralama',
      shortName: 'Rent a Car',
      emoji: '🔑',
      color: 0x14b8a6,
      pos: [27, 0, 7],
      tagHeight: 6.5,
      requiredLevel: 4,
      unlockCost: 75000,
      description: 'Galerideki araçları filo kiralamaya vererek günlük garanti pasif gelir sağla.',
      builder: createRentACarBuilding,
    },
    {
      id: 'branches',
      route: '/branches',
      name: 'Şube İmparatorluğu & Plazalar',
      shortName: 'Plaza & Şubeler',
      subtitle: 'Galeri Genişletme & Prestij',
      emoji: '🏢',
      color: 0xc9a96e,
      pos: [27, 0, 27],
      tagHeight: 15.5,
      requiredLevel: 5,
      unlockCost: 100000,
      description: 'Yeni şubeler ve mega plazalar açarak galerinin araç kapasitesini katla.',
      builder: createCorporatePlazaBuilding,
    },
  ];

  // Helper 3D Primitives
  function createBox(w, h, d, color, castShadow = true, receiveShadow = true) {
    const geo = new THREE.BoxGeometry(w, h, d);
    const mat = new THREE.MeshLambertMaterial({ color: color, flatShading: true });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.castShadow = castShadow;
    mesh.receiveShadow = receiveShadow;
    return mesh;
  }

  // --- Building Model Builders ---
  function createCentralShowroomGroup() {
    const group = new THREE.Group();
    const base = createBox(13, 5.0, 8, 0x1e293b);
    base.position.y = 2.5;
    group.add(base);

    const glassMat = new THREE.MeshLambertMaterial({ color: 0x38bdf8, transparent: true, opacity: 0.75 });
    const glass = new THREE.Mesh(new THREE.BoxGeometry(12.2, 3.4, 0.4), glassMat);
    glass.position.set(0, 2.4, 3.9);
    group.add(glass);

    const demoCar = createLowPolyCar(0xef4444);
    demoCar.position.set(0, 0.8, 1.2);
    demoCar.scale.set(0.85, 0.85, 0.85);
    group.add(demoCar);

    const signBoard = createBox(11, 2.0, 0.5, 0x0284c7);
    signBoard.position.set(0, 5.8, 3.8);
    group.add(signBoard);

    const neonGeo = new THREE.BoxGeometry(11.4, 0.25, 0.6);
    const neonMat = new THREE.MeshBasicMaterial({ color: 0x38bdf8 });
    neonMaterials.push(neonMat);
    const neonMesh = new THREE.Mesh(neonGeo, neonMat);
    neonMesh.position.set(0, 6.9, 3.8);
    group.add(neonMesh);

    const pole = createBox(0.15, 4.5, 0.15, 0xe2e8f0);
    pole.position.set(5.0, 7.0, -2.5);
    group.add(pole);

    const flag = createBox(1.5, 0.9, 0.08, 0x0284c7);
    flag.position.set(5.75, 8.8, -2.5);
    group.add(flag);

    return group;
  }

  function createWorkshopBuilding() {
    const g = new THREE.Group();
    const main = createBox(8, 4.5, 7, 0xb45309);
    main.position.y = 2.25;
    g.add(main);

    const roof = createGableRoof(8.4, 2.0, 7.4, 0x7c2d12);
    roof.position.y = 4.5;
    g.add(roof);

    const chimney = createBox(1.4, 7.5, 1.4, 0x991b1b);
    chimney.position.set(-2.8, 3.75, -2.2);
    g.add(chimney);

    const smokeGroup = new THREE.Group();
    smokeGroup.position.set(-2.8, 7.6, -2.2);
    for (let i = 0; i < 3; i++) {
      const puff = new THREE.Mesh(
        new THREE.DodecahedronGeometry(0.5 + i * 0.2),
        new THREE.MeshLambertMaterial({ color: 0xffffff, transparent: true, opacity: 0.65 - i * 0.15 })
      );
      puff.position.y = i * 0.7;
      smokeGroup.add(puff);
      animatedSmokes.push({ mesh: puff, initY: i * 0.7, speed: 0.8 + i * 0.2 });
    }
    g.add(smokeGroup);

    const door = createBox(4.0, 3.0, 0.2, 0x334155);
    door.position.set(0, 1.5, 3.6);
    g.add(door);

    return g;
  }

  function createCarWashBuilding() {
    const g = new THREE.Group();
    const frame = createBox(7.5, 4.2, 6.5, 0x0891b2);
    frame.position.y = 2.1;
    g.add(frame);

    const glass = new THREE.Mesh(
      new THREE.BoxGeometry(5.5, 3.2, 6.7),
      new THREE.MeshLambertMaterial({ color: 0x67e8f9, transparent: true, opacity: 0.6 })
    );
    glass.position.set(0, 1.8, 0);
    g.add(glass);

    const tank = new THREE.Mesh(
      new THREE.CylinderGeometry(1.4, 1.4, 2.8, 12),
      new THREE.MeshLambertMaterial({ color: 0x0284c7 })
    );
    tank.position.set(0, 5.2, 0);
    tank.rotation.z = Math.PI / 2;
    g.add(tank);

    const puddle = new THREE.Mesh(
      new THREE.CylinderGeometry(2.2, 2.2, 0.05, 12),
      new THREE.MeshBasicMaterial({ color: 0x38bdf8, transparent: true, opacity: 0.7 })
    );
    puddle.position.set(0, 0.06, 4.2);
    g.add(puddle);

    return g;
  }

  function createTuningBuilding() {
    const g = new THREE.Group();
    const body = createBox(7.5, 4.5, 7.5, 0x18181b);
    body.position.y = 2.25;
    g.add(body);

    const neon = createBox(7.7, 0.25, 7.7, 0xfacc15);
    neon.position.y = 3.8;
    neonMaterials.push(neon.material);
    g.add(neon);

    const wing = createBox(5.0, 0.35, 1.0, 0xeab308);
    wing.position.set(0, 5.2, 0);
    g.add(wing);

    return g;
  }

  function createMarketplaceBuilding() {
    const g = new THREE.Group();
    const base = createBox(9, 0.4, 8, 0x64748b);
    base.position.y = 0.2;
    g.add(base);

    const canopy = createBox(8, 0.3, 7, 0x2563eb);
    canopy.position.y = 3.8;
    g.add(canopy);

    for (let x of [-3.5, 3.5]) {
      for (let z of [-3.0, 3.0]) {
        const pole = createBox(0.2, 3.6, 0.2, 0xffffff);
        pole.position.set(x, 1.9, z);
        g.add(pole);
      }
    }

    const car = createLowPolyCar(0x3b82f6);
    car.position.set(0, 0.55, 0);
    g.add(car);

    return g;
  }

  function createAuctionBuilding() {
    const g = new THREE.Group();
    const tier1 = new THREE.Mesh(new THREE.CylinderGeometry(4.8, 5.0, 2.2, 16), new THREE.MeshLambertMaterial({ color: 0xdc2626 }));
    tier1.position.y = 1.1;
    tier1.castShadow = true;
    g.add(tier1);

    const tier2 = new THREE.Mesh(new THREE.CylinderGeometry(3.6, 3.8, 2.2, 16), new THREE.MeshLambertMaterial({ color: 0xef4444 }));
    tier2.position.y = 3.3;
    tier2.castShadow = true;
    g.add(tier2);

    const gavel = new THREE.Mesh(new THREE.CylinderGeometry(0.7, 0.7, 1.2, 8), new THREE.MeshLambertMaterial({ color: 0xf59e0b }));
    gavel.position.set(0, 5.0, 0);
    g.add(gavel);

    return g;
  }

  function createScrapyardBuilding() {
    const g = new THREE.Group();
    const shed = createBox(6.5, 3.2, 5.5, 0xc2410c);
    shed.position.y = 1.6;
    g.add(shed);

    const roof = createGableRoof(6.9, 1.4, 5.9, 0x7c2d12);
    roof.position.y = 3.2;
    g.add(roof);

    const pile1 = createBox(2.0, 1.6, 2.0, 0x475569);
    pile1.position.set(4.0, 0.8, 1.8);
    g.add(pile1);

    const pile2 = createBox(1.8, 1.2, 1.8, 0x78350f);
    pile2.position.set(3.8, 0.6, -1.8);
    g.add(pile2);

    const crane = createBox(0.4, 6.5, 0.4, 0xeab308);
    crane.position.set(-3.2, 3.25, 2.5);
    crane.rotation.z = -0.2;
    g.add(crane);

    return g;
  }

  function createBlackMarketBuilding() {
    const g = new THREE.Group();
    const hangar = createBox(7.5, 3.8, 6.5, 0x1e293b);
    hangar.position.y = 1.9;
    g.add(hangar);

    const beacon = new THREE.Mesh(new THREE.CylinderGeometry(0.35, 0.35, 0.5, 8), new THREE.MeshBasicMaterial({ color: 0xef4444 }));
    beacon.position.set(0, 4.1, 0);
    g.add(beacon);

    const fence = createBox(9.0, 1.1, 8.0, 0x64748b, false, false);
    fence.position.y = 0.55;
    g.add(fence);

    return g;
  }

  function createBankBuilding() {
    const g = new THREE.Group();
    const base = createBox(8.5, 1.0, 7.5, 0xf1f5f9);
    base.position.y = 0.5;
    g.add(base);

    for (let x of [-3.0, -1.0, 1.0, 3.0]) {
      const col = new THREE.Mesh(new THREE.CylinderGeometry(0.35, 0.4, 4.6, 10), new THREE.MeshLambertMaterial({ color: 0xffffff }));
      col.position.set(x, 3.3, 3.0);
      col.castShadow = true;
      g.add(col);
    }

    const hall = createBox(7.8, 4.6, 5.5, 0xe2e8f0);
    hall.position.set(0, 3.3, -0.6);
    g.add(hall);

    const pediment = createGableRoof(8.6, 2.0, 7.6, 0xd97706);
    pediment.position.y = 5.6;
    g.add(pediment);

    return g;
  }

  function createStockMarketBuilding() {
    const g = new THREE.Group();
    const tower = createBox(6.5, 13, 6.5, 0x0f172a);
    tower.position.y = 6.5;
    g.add(tower);

    const glass = createBox(6.0, 12, 6.0, 0x38bdf8);
    glass.position.y = 6.5;
    g.add(glass);

    const ticker = createBox(6.7, 0.7, 6.7, 0x22c55e);
    ticker.position.y = 8.0;
    neonMaterials.push(ticker.material);
    g.add(ticker);

    const antenna = createBox(0.2, 4.0, 0.2, 0xffffff);
    antenna.position.set(0, 15.0, 0);
    g.add(antenna);

    return g;
  }

  function createInvestmentVaultBuilding() {
    const g = new THREE.Group();
    const vault = createBox(7.0, 5.0, 7.0, 0x475569);
    vault.position.y = 2.5;
    g.add(vault);

    const trim = createBox(7.3, 0.35, 7.3, 0xd97706);
    trim.position.y = 4.8;
    g.add(trim);

    const gold = createBox(2.0, 1.0, 1.5, 0xf59e0b);
    gold.position.set(0, 5.6, 0);
    g.add(gold);

    return g;
  }

  function createRentACarBuilding() {
    const g = new THREE.Group();
    const hub = createBox(7.5, 4.2, 6.5, 0x0f766e);
    hub.position.y = 2.1;
    g.add(hub);

    const lobby = createBox(7.0, 2.2, 2.2, 0x2dd4bf);
    lobby.position.set(0, 1.3, 3.0);
    g.add(lobby);

    const sign = createBox(3.6, 1.2, 0.35, 0x14b8a6);
    sign.position.set(0, 4.8, 2.2);
    g.add(sign);

    return g;
  }

  function createCorporatePlazaBuilding() {
    const g = new THREE.Group();
    const tower1 = createBox(5.0, 11, 5.0, 0x1e293b);
    tower1.position.set(-2.8, 5.5, 0);
    g.add(tower1);

    const tower2 = createBox(5.0, 14, 5.0, 0x334155);
    tower2.position.set(2.8, 7.0, 0);
    g.add(tower2);

    const bridge = createBox(3.6, 1.4, 2.2, 0x0284c7);
    bridge.position.set(0, 8.8, 0);
    g.add(bridge);

    const helipad = new THREE.Mesh(new THREE.CylinderGeometry(2.2, 2.2, 0.2, 16), new THREE.MeshLambertMaterial({ color: 0x64748b }));
    helipad.position.set(2.8, 14.1, 0);
    g.add(helipad);

    const beacon = new THREE.Mesh(new THREE.SphereGeometry(0.3, 8, 8), new THREE.MeshBasicMaterial({ color: 0x22c55e }));
    beacon.position.set(2.8, 14.4, 0);
    neonMaterials.push(beacon.material);
    g.add(beacon);

    return g;
  }

  function createGableRoof(w, h, d, color) {
    const geo = new THREE.ConeGeometry(w * 0.65, h, 4);
    const mat = new THREE.MeshLambertMaterial({ color: color, flatShading: true });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.rotation.y = Math.PI / 4;
    mesh.castShadow = true;
    mesh.receiveShadow = true;
    return mesh;
  }

  function createLowPolyCar(bodyColor) {
    const car = new THREE.Group();
    const body = createBox(2.0, 0.65, 3.6, bodyColor);
    body.position.y = 0.5;
    car.add(body);

    const cabin = createBox(1.6, 0.6, 2.0, 0x1e293b);
    cabin.position.set(0, 1.0, -0.2);
    car.add(cabin);

    const wheelGeo = new THREE.CylinderGeometry(0.32, 0.32, 0.25, 10);
    const wheelMat = new THREE.MeshLambertMaterial({ color: 0x18181b });
    for (let x of [-1.05, 1.05]) {
      for (let z of [-1.1, 1.1]) {
        const wheel = new THREE.Mesh(wheelGeo, wheelMat);
        wheel.rotation.z = Math.PI / 2;
        wheel.position.set(x, 0.32, z);
        car.add(wheel);
      }
    }

    const hlGeo = new THREE.BoxGeometry(0.35, 0.18, 0.1);
    const hlMat = new THREE.MeshBasicMaterial({ color: 0xfef08a });
    const hl1 = new THREE.Mesh(hlGeo, hlMat);
    hl1.position.set(-0.6, 0.55, 1.85);
    car.add(hl1);
    const hl2 = new THREE.Mesh(hlGeo, hlMat);
    hl2.position.set(0.6, 0.55, 1.85);
    car.add(hl2);

    return car;
  }

  // --- 7. Instantiate Buildings & Screen Tags ---
  BUILDING_DEFS.forEach(def => {
    const buildingGroup = def.builder();
    buildingGroup.position.set(def.pos[0], def.pos[1], def.pos[2]);

    // 3D Floating Lock Hologram Ring
    const lockHologram = new THREE.Group();
    const lockRing = new THREE.Mesh(
      new THREE.TorusGeometry(1.2, 0.18, 8, 16),
      new THREE.MeshBasicMaterial({ color: 0xef4444, wireframe: true })
    );
    lockRing.rotation.x = Math.PI / 2;
    lockHologram.add(lockRing);
    lockHologram.position.set(0, def.tagHeight - 2.0, 0);
    lockHologram.visible = false;
    buildingGroup.add(lockHologram);

    // Register mesh collision
    buildingGroup.traverse(child => {
      if (child.isMesh) {
        child.userData = {
          route: def.route,
          name: def.name,
          shortName: def.shortName,
          subtitle: def.subtitle,
          emoji: def.emoji,
          color: def.color,
          requiredLevel: def.requiredLevel,
          unlockCost: def.unlockCost,
          description: def.description,
          buildingDef: def,
          buildingGroup: buildingGroup,
        };
        interactableObjects.push(child);
      }
    });

    worldGroup.add(buildingGroup);

    // Create 2D Screen Tag DOM Element
    const tagEl = document.createElement('div');
    tagEl.className = 'building-tag';
    tagEl.addEventListener('click', (e) => {
      e.stopPropagation();
      onBuildingClick(def);
    });
    tagsContainer.appendChild(tagEl);

    buildingInstances.push({
      def: def,
      group: buildingGroup,
      lockHologram: lockHologram,
      tagEl: tagEl,
      worldPos: new THREE.Vector3(def.pos[0], def.tagHeight, def.pos[2]),
    });
  });

  // --- 8. Suburban Residential Houses & Nature ---
  const HOUSE_COORDS = [
    [-44, -44, 0xc2410c], [-44, 44, 0x1e3a8a],
    [44, -44, 0x047857], [44, 44, 0x7c3aed],
    [-44, -18, 0xb91c1c], [44, -18, 0x0f766e],
    [-44, 18, 0x854d0e], [44, 18, 0x15803d],
  ];

  HOUSE_COORDS.forEach(([x, z, col]) => {
    const h = new THREE.Group();
    h.position.set(x, 0, z);
    const body = createBox(3.6, 2.6, 3.6, 0xfef3c7);
    body.position.y = 1.3;
    h.add(body);
    const roof = createGableRoof(4.0, 1.6, 4.0, col);
    roof.position.y = 2.6;
    h.add(roof);
    worldGroup.add(h);
  });

  function createPineTree(x, z, scale = 1.0) {
    const t = new THREE.Group();
    t.position.set(x, 0, z);
    t.scale.set(scale, scale, scale);
    const trunk = createBox(0.4, 1.6, 0.4, 0x5a381e);
    trunk.position.y = 0.8;
    t.add(trunk);
    for (let i = 0; i < 3; i++) {
      const foliage = new THREE.Mesh(
        new THREE.ConeGeometry(1.6 - i * 0.35, 1.6, 6),
        new THREE.MeshLambertMaterial({ color: i === 2 ? 0x166534 : 0x15803d, flatShading: true })
      );
      foliage.position.y = 2.0 + i * 0.9;
      foliage.castShadow = true;
      t.add(foliage);
    }
    worldGroup.add(t);
  }

  function createOakTree(x, z, scale = 1.0) {
    const t = new THREE.Group();
    t.position.set(x, 0, z);
    t.scale.set(scale, scale, scale);
    const trunk = createBox(0.4, 1.6, 0.4, 0x78350f);
    trunk.position.y = 0.8;
    t.add(trunk);
    const leaves = new THREE.Mesh(
      new THREE.DodecahedronGeometry(1.4),
      new THREE.MeshLambertMaterial({ color: 0x22c55e, flatShading: true })
    );
    leaves.position.y = 2.6;
    leaves.castShadow = true;
    t.add(leaves);
    worldGroup.add(t);
  }

  function isBlocked(x, z) {
    if (Math.abs(x - 18) < 4.2 || Math.abs(x + 18) < 4.2) return true;
    if (Math.abs(z - 18) < 4.2 || Math.abs(z + 18) < 4.2) return true;
    if (Math.abs(x - 36) < 4.2 || Math.abs(x + 36) < 4.2) return true;
    if (Math.abs(z - 36) < 4.2 || Math.abs(z + 36) < 4.2) return true;
    if (Math.abs(x) < 13 && Math.abs(z) < 13) return true;
    for (let b of BUILDING_DEFS) {
      const dx = x - b.pos[0];
      const dz = z - b.pos[2];
      if (Math.sqrt(dx * dx + dz * dz) < 6.5) return true;
    }
    return false;
  }

  for (let i = 0; i < 45; i++) {
    const rx = (Math.random() - 0.5) * 70;
    const rz = (Math.random() - 0.5) * 70;
    if (isBlocked(rx, rz)) continue;
    if (i % 2 === 0) createPineTree(rx, rz, 0.85 + Math.random() * 0.25);
    else createOakTree(rx, rz, 0.85 + Math.random() * 0.25);
  }

  for (let i = 0; i < 180; i++) {
    const angle = Math.random() * Math.PI * 2;
    const dist = 45 + Math.random() * 65;
    const fx = Math.cos(angle) * dist;
    const fz = Math.sin(angle) * dist;
    const scale = 1.1 + Math.random() * 0.7;
    if (i % 2 === 0) createPineTree(fx, fz, scale);
    else createOakTree(fx, fz, scale);
  }

  // --- 9. Street Light Poles ---
  function createStreetLamp(x, z) {
    const g = new THREE.Group();
    g.position.set(x, 0, z);
    const pole = createBox(0.18, 4.0, 0.18, 0x64748b);
    pole.position.y = 2.0;
    g.add(pole);

    const arm = createBox(1.0, 0.12, 0.18, 0x64748b);
    arm.position.set(0.45, 4.0, 0);
    g.add(arm);

    const bulb = new THREE.Mesh(new THREE.SphereGeometry(0.18, 8, 8), new THREE.MeshBasicMaterial({ color: 0xfef08a }));
    bulb.position.set(0.9, 3.8, 0);
    g.add(bulb);

    const light = new THREE.PointLight(0xfef08a, 0, 10);
    light.position.set(0.9, 3.6, 0);
    g.add(light);
    streetLights.push(light);

    worldGroup.add(g);
  }

  [-28, -10, 10, 28].forEach(pos => {
    createStreetLamp(pos, -14.4);
    createStreetLamp(pos, 14.4);
    createStreetLamp(-14.4, pos);
    createStreetLamp(14.4, pos);
  });

  // --- 10. Traffic System ---
  const ROAD_LOOPS = [
    [
      { x: -16.5, z: -16.5 },
      { x: 16.5, z: -16.5 },
      { x: 16.5, z: 16.5 },
      { x: -16.5, z: 16.5 },
    ],
    [
      { x: -19.5, z: 19.5 },
      { x: 19.5, z: 19.5 },
      { x: 19.5, z: -19.5 },
      { x: -19.5, z: -19.5 },
    ],
    [
      { x: -34.5, z: -34.5 },
      { x: 34.5, z: -34.5 },
      { x: 34.5, z: 34.5 },
      { x: -34.5, z: 34.5 },
    ]
  ];

  const CAR_COLORS = [0xef4444, 0x3b82f6, 0x10b981, 0xf59e0b, 0xa855f7, 0x06b6d4];
  for (let i = 0; i < 9; i++) {
    const carMesh = createLowPolyCar(CAR_COLORS[i % CAR_COLORS.length]);
    worldGroup.add(carMesh);
    const loop = ROAD_LOOPS[i % ROAD_LOOPS.length];
    animatedCars.push({
      mesh: carMesh,
      loop: loop,
      waypointIndex: i % loop.length,
      progress: (i * 0.33) % 1.0,
      speed: 0.16 + (i % 3) * 0.03,
    });
  }

  // --- 11. State & Tags Update Function ---
  function updateCityTags() {
    buildingInstances.forEach(item => {
      const def = item.def;
      const isUnlocked = gameState.unlockedBuildings.includes(def.route) || def.route === '/showroom';
      const badge = gameState.badges[def.route];

      item.lockHologram.visible = !isUnlocked;

      let html = '';
      if (badge) {
        html += `<div class="notification-pill">🔔 ${badge}</div>`;
      }

      if (isUnlocked) {
        html += `<div class="tag-pill">${def.emoji} ${def.shortName || def.name}</div>`;
      } else {
        const costShort = def.unlockCost >= 1000 ? `${Math.round(def.unlockCost / 1000)}B` : `₺${def.unlockCost}`;
        html += `<div class="tag-pill locked">🔒 ${def.shortName || def.name} <span class="lock-badge">Lv.${def.requiredLevel}</span></div>`;
      }

      item.tagEl.innerHTML = html;
    });
  }

  // --- 12. Raycaster & Interactive Hover/Click ---
  const raycaster = new THREE.Raycaster();
  const mouse = new THREE.Vector2();
  let hoveredBuildingDef = null;

  function onPointerMove(e) {
    const rect = canvas.getBoundingClientRect();
    mouse.x = ((e.clientX - rect.left) / rect.width) * 2 - 1;
    mouse.y = -((e.clientY - rect.top) / rect.height) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects(interactableObjects, false);

    if (intersects.length > 0) {
      const hit = intersects[0].object;
      const data = hit.userData;
      if (data && data.name) {
        hoveredBuildingDef = data.buildingDef || data;
        const def = hoveredBuildingDef;
        const isUnlocked = gameState.unlockedBuildings.includes(def.route) || def.route === '/showroom';
        const badge = gameState.badges[def.route];

        let html = `<div class="tt-title">${def.emoji || '🏢'} ${def.name}</div>`;
        html += `<div class="tt-sub">${def.subtitle || ''}</div>`;

        if (badge) {
          html += `<div class="tt-badge-notify">🔔 ${badge}</div><br>`;
        }

        if (!isUnlocked) {
          const canUnlock = gameState.level >= def.requiredLevel && gameState.balance >= def.unlockCost;
          html += `<div class="tt-status-lock">🔒 Kilitli · Seviye ${def.requiredLevel} · ₺${def.unlockCost.toLocaleString('tr-TR')}</div>`;
          html += `<div class="tt-action" style="color:${canUnlock ? '#4ade80' : '#f87171'}">${canUnlock ? '👉 Tıkla ve Kilidi Aç' : '⚠️ Seviye / Bakiye Yetersiz'}</div>`;
        } else {
          html += `<div class="tt-action">👉 Giriş Yapmak İçin Tıkla</div>`;
        }

        tooltip.style.display = 'block';
        tooltip.innerHTML = html;
        tooltip.style.left = `${e.clientX}px`;
        tooltip.style.top = `${e.clientY - 12}px`;
        canvas.style.cursor = 'pointer';
        return;
      }
    }

    hoveredBuildingDef = null;
    tooltip.style.display = 'none';
    canvas.style.cursor = 'grab';
  }

  function onBuildingClick(def) {
    const isUnlocked = gameState.unlockedBuildings.includes(def.route) || def.route === '/showroom';
    const payload = {
      type: 'BUILDING_CLICK',
      route: def.route,
      name: def.name,
      shortName: def.shortName,
      subtitle: def.subtitle,
      description: def.description,
      emoji: def.emoji,
      requiredLevel: def.requiredLevel,
      unlockCost: def.unlockCost,
      isUnlocked: isUnlocked,
    };

    if (window.FlutterBridge && window.FlutterBridge.postMessage) {
      window.FlutterBridge.postMessage(JSON.stringify(payload));
    }
    if (window.parent && window.parent.postMessage) {
      window.parent.postMessage(payload, '*');
    }
  }

  window.updateCityFromFlutter = function(msg) {
    if (!msg || typeof msg !== 'object') return;
    if (msg.playerLevel !== undefined) gameState.level = msg.playerLevel;
    if (msg.playerBalance !== undefined) gameState.balance = msg.playerBalance;
    if (msg.unlockedBuildings) gameState.unlockedBuildings = msg.unlockedBuildings;
    if (msg.badges) gameState.badges = msg.badges;
    if (msg.hour !== undefined) applyTimeOfDay(msg.hour);
    updateCityTags();
  };

  let pointerDownPos = { x: 0, y: 0 };
  let hasDragged = false;

  canvas.addEventListener('pointerdown', (e) => {
    pointerDownPos = { x: e.clientX, y: e.clientY };
    hasDragged = false;
  }, false);

  function onPointerClick(e) {
    if (hasDragged) return;
    if (controls.state !== -1) return;

    const rect = canvas.getBoundingClientRect();
    mouse.x = ((e.clientX - rect.left) / rect.width) * 2 - 1;
    mouse.y = -((e.clientY - rect.top) / rect.height) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObjects(interactableObjects, false);

    if (intersects.length > 0) {
      const hit = intersects[0].object;
      const data = hit.userData;
      if (data && data.route) {
        onBuildingClick(data.buildingDef || data);
      }
    }
  }

  canvas.addEventListener('mousemove', (e) => {
    const dx = e.clientX - pointerDownPos.x;
    const dy = e.clientY - pointerDownPos.y;
    if (dx * dx + dy * dy > 36) {
      hasDragged = true;
    }
    onPointerMove(e);
  }, false);

  canvas.addEventListener('click', onPointerClick, false);

  // Smooth recenter to Showroom / Center Plaza
  window.recenterCityView = function () {
    const startCamPos = camera.position.clone();
    const startTarget = controls.target.clone();
    const destTarget = new THREE.Vector3(0, 0, 0);
    const offset = new THREE.Vector3(72, 68, 72);
    const destCamPos = destTarget.clone().add(offset);
    const startTime = performance.now();
    const duration = 600;

    function step(now) {
      const elapsed = now - startTime;
      const progress = Math.min(elapsed / duration, 1.0);
      const ease = progress < 0.5 ? 2 * progress * progress : -1 + (4 - 2 * progress) * progress;

      camera.position.lerpVectors(startCamPos, destCamPos, ease);
      controls.target.lerpVectors(startTarget, destTarget, ease);
      controls.update();

      if (progress < 1.0) {
        requestAnimationFrame(step);
      }
    }
    requestAnimationFrame(step);
  };

  // --- 13. Flutter <-> JS Bridge (postMessage) ---
  window.addEventListener('message', function (event) {
    if (!event.data || typeof event.data !== 'object') return;
    const msg = event.data;

    if (msg.type === 'SET_TIME_OF_DAY') {
      applyTimeOfDay(msg.hour || 12);
    } else if (msg.type === 'UPDATE_CITY_STATE') {
      window.updateCityFromFlutter(msg);
    }
  });

  function applyTimeOfDay(hour) {
    const isNight = hour >= 21 || hour < 6;
    const isSunset = hour >= 18 && hour < 21;

    if (isNight) {
      scene.background.setHex(0x0f172a);
      scene.fog.color.setHex(0x0f172a);
      ambientLight.color.setHex(0x312e81);
      ambientLight.intensity = 0.45;
      sunLight.intensity = 0.2;
      streetLights.forEach(l => l.intensity = 1.4);
      neonMaterials.forEach(m => m.color.setHex(0x38bdf8));
    } else if (isSunset) {
      scene.background.setHex(0xfda4af);
      scene.fog.color.setHex(0xfda4af);
      ambientLight.color.setHex(0xfb7185);
      ambientLight.intensity = 0.75;
      sunLight.color.setHex(0xf97316);
      sunLight.intensity = 1.1;
      streetLights.forEach(l => l.intensity = 0.8);
    } else {
      scene.background.setHex(0xa5f3fc);
      scene.fog.color.setHex(0xbae6fd);
      ambientLight.color.setHex(0xfffbeb);
      ambientLight.intensity = 0.65;
      sunLight.color.setHex(0xfff7ed);
      sunLight.intensity = 1.4;
      streetLights.forEach(l => l.intensity = 0.0);
    }
  }

  // --- 14. Animation Loop & Screen Tag Projection ---
  const clock = new THREE.Clock();
  const tempV = new THREE.Vector3();

  function animate() {
    requestAnimationFrame(animate);
    const delta = clock.getDelta();

    controls.update();

    // Rotate Lock Holograms
    buildingInstances.forEach(item => {
      if (item.lockHologram.visible) {
        item.lockHologram.rotation.y += delta * 1.5;
      }
    });

    // Animate Chimney Smoke
    animatedSmokes.forEach(s => {
      s.mesh.position.y += delta * s.speed;
      s.mesh.scale.multiplyScalar(1.006);
      if (s.mesh.position.y > s.initY + 3.0) {
        s.mesh.position.y = s.initY;
        s.mesh.scale.set(1, 1, 1);
      }
    });

    // Animate Traffic
    animatedCars.forEach(car => {
      const loop = car.loop;
      const p1 = loop[car.waypointIndex];
      const p2 = loop[(car.waypointIndex + 1) % loop.length];

      car.progress += delta * car.speed;
      if (car.progress >= 1.0) {
        car.progress = 0;
        car.waypointIndex = (car.waypointIndex + 1) % loop.length;
      }

      const cx = p1.x + (p2.x - p1.x) * car.progress;
      const cz = p1.z + (p2.z - p1.z) * car.progress;
      car.mesh.position.set(cx, 0, cz);

      const angle = Math.atan2(p2.x - p1.x, p2.z - p1.z);
      car.mesh.rotation.y = angle;
    });

    // Animate Floating Clouds
    animatedClouds.forEach(c => {
      c.group.position.x += delta * c.speed;
      if (c.group.position.x > 180) {
        c.group.position.x = -180;
      }
    });

    // Project 3D Building Coordinates into 2D Screen Space for Floating Tags
    const halfWidth = width / 2;
    const halfHeight = height / 2;

    buildingInstances.forEach(item => {
      tempV.copy(item.worldPos);
      tempV.project(camera);

      // Behind camera check
      if (tempV.z > 1.0) {
        item.tagEl.style.display = 'none';
        return;
      }

      const screenX = (tempV.x * halfWidth) + halfWidth;
      const screenY = (-(tempV.y * halfHeight)) + halfHeight;

      item.tagEl.style.display = 'flex';
      item.tagEl.style.left = `${screenX}px`;
      item.tagEl.style.top = `${screenY}px`;
    });

    // Clamp camera target across the city bounds
    controls.target.x = THREE.MathUtils.clamp(controls.target.x, -80, 80);
    controls.target.z = THREE.MathUtils.clamp(controls.target.z, -80, 80);

    renderer.render(scene, camera);
  }

  window.addEventListener('resize', () => {
    const w = container.clientWidth || window.innerWidth;
    const h = container.clientHeight || window.innerHeight;
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
    renderer.setSize(w, h);
  });

  updateCityTags();
  animate();
  applyTimeOfDay(12);
})();
